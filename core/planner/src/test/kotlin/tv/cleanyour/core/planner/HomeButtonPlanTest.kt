package tv.cleanyour.core.planner

import tv.cleanyour.core.model.BlobRef
import tv.cleanyour.core.model.Component
import tv.cleanyour.core.model.EnabledState
import tv.cleanyour.core.model.LauncherArtifact
import tv.cleanyour.core.model.Op
import tv.cleanyour.core.model.PackageName
import tv.cleanyour.core.model.PackageState
import tv.cleanyour.core.model.Prior
import tv.cleanyour.core.model.SettingKey
import tv.cleanyour.core.model.Sha256
import tv.cleanyour.core.planner.PlannerFixtures.installedLauncher
import tv.cleanyour.core.planner.PlannerFixtures.plan
import tv.cleanyour.core.planner.PlannerFixtures.refused
import tv.cleanyour.core.planner.PlannerFixtures.snapshot
import tv.cleanyour.testing.fixtures.Samples
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

// RFC-HOME-BUTTON-1: the Home button on a Fire TV, which takes no other home screen.
class HomeButtonPlanTest {
    private val launcher = Samples.launcherArtifact()
    private val pkg = PackageName("tv.cleanyour.homeinterceptor")
    private val signer = Sha256("d".repeat(64))
    private val interceptor = LauncherArtifact(pkg, 1, "0.1", Sha256("c".repeat(64)), signer, BlobRef(Sha256("c".repeat(64)), 16_852, "bundled:cleanyourtv-interceptor.apk"))
    private val service = "tv.cleanyour.homeinterceptor/.HomeService"
    private val amazonHome = Component(PackageName("com.amazon.tv.launcher"), ".ui.HomeActivity_vNext")
    private val request = PlanRequest.UseHomeButton(launcher, interceptor)

    private fun fire(extra: Map<PackageName, PackageState> = emptyMap(), settings: Map<SettingKey, String?> = emptyMap()) =
        snapshot(home = amazonHome, claimants = listOf(amazonHome), extra = extra).withSettings(settings)

    private fun interceptorOnTv(signer: Sha256 = this.signer) = pkg to PackageState(EnabledState.ENABLED, false, 1, signer, false, false, "Home Interceptor", true)
    private fun ops(p: Plan) = p.steps.map { it.op }

    @Test fun aFireTvGetsBothAppsThenTheServiceSwitchedOn() {
        val p = plan(request, fire())
        assertEquals(PlanKind.HOME_BUTTON, p.kind)
        val installs = p.steps.map { it.op }.filter { it is Op.InstallStream || it is Op.Install }
        assertEquals(2, installs.size)
        val puts = ops(p).filterIsInstance<Op.SettingsPut>()
        assertEquals(listOf(Op.SettingsPut(SettingKey.ENABLED_ACCESSIBILITY, service), Op.SettingsPut(SettingKey.ACCESSIBILITY_ENABLED, "1")), puts)
        assertTrue(p.steps.all { it.op !is Op.SetHome }, "set-home-activity is ignored on Fire OS and is never sent")
        assertTrue(p.summary.homeScreenPossible)
    }

    @Test fun theServiceJoinsTheListTheTvHasAndKeepsItsPriorValue() {
        val p = plan(request, fire(extra = mapOf(installedLauncher()), settings = mapOf(SettingKey.ENABLED_ACCESSIBILITY to "com.example/.Reader", SettingKey.ACCESSIBILITY_ENABLED to "1")))
        val put = p.steps.single { it.op is Op.SettingsPut && (it.op as Op.SettingsPut).key == SettingKey.ENABLED_ACCESSIBILITY }
        assertEquals(Op.SettingsPut(SettingKey.ENABLED_ACCESSIBILITY, "com.example/.Reader:$service"), put.op)
        assertEquals(Prior(settingValue = "com.example/.Reader"), put.prior)
        assertEquals(1, ops(p).count { it is Op.InstallStream || it is Op.Install }, "the launcher was already there")
    }

    @Test fun accessibilityIsNeverSwitchedOnOverSomeoneElsesServices() {
        val reasons = refused(request, fire(settings = mapOf(SettingKey.ENABLED_ACCESSIBILITY to "com.example/.Reader", SettingKey.ACCESSIBILITY_ENABLED to "0")))
        assertEquals(listOf(DefaultPlanner.REASON_ACCESSIBILITY_OFF_WITH_OTHERS), reasons)
        // With nothing else listed, switching it on starts only ours.
        assertTrue(ops(plan(request, fire(settings = mapOf(SettingKey.ENABLED_ACCESSIBILITY to "null", SettingKey.ACCESSIBILITY_ENABLED to "0")))).any { it == Op.SettingsPut(SettingKey.ACCESSIBILITY_ENABLED, "1") })
    }

    @Test fun anAlreadyActiveHomeButtonPlansNothing() {
        val p = plan(request, fire(extra = mapOf(installedLauncher(), interceptorOnTv()),
            settings = mapOf(SettingKey.ENABLED_ACCESSIBILITY to service, SettingKey.ACCESSIBILITY_ENABLED to "1")))
        assertTrue(p.steps.isEmpty())
    }

    @Test fun otherKeysAndOtherTvsAreRefused() {
        assertEquals(listOf(DefaultPlanner.REASON_INTERCEPTOR_OTHER_KEY), refused(request, fire(extra = mapOf(interceptorOnTv(signer = Sha256("e".repeat(64)))))))
        assertEquals(listOf(DefaultPlanner.REASON_NOT_FIRE_TV), refused(request, snapshot()))
    }

    @Test fun givingHomeBackTakesOnlyOursOutAndUninstallsIt() {
        val p = plan(PlanRequest.GiveHomeBack(pkg), fire(extra = mapOf(interceptorOnTv()),
            settings = mapOf(SettingKey.ENABLED_ACCESSIBILITY to "com.example/.Reader:$service", SettingKey.ACCESSIBILITY_ENABLED to "1")))
        assertEquals(PlanKind.HOME_BUTTON_OFF, p.kind)
        assertEquals(listOf(Op.SettingsPut(SettingKey.ENABLED_ACCESSIBILITY, "com.example/.Reader"), Op.Uninstall(pkg)), ops(p))
        val alone = plan(PlanRequest.GiveHomeBack(pkg), fire(extra = mapOf(interceptorOnTv()), settings = mapOf(SettingKey.ENABLED_ACCESSIBILITY to service, SettingKey.ACCESSIBILITY_ENABLED to "1")))
        assertEquals(Op.SettingsPut(SettingKey.ENABLED_ACCESSIBILITY, null), ops(alone).first())
    }
}
