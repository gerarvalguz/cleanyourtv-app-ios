package tv.cleanyour.core.flows

import app.cash.turbine.test
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runTest
import tv.cleanyour.core.model.BlobRef
import tv.cleanyour.core.model.EnabledState
import tv.cleanyour.core.model.LauncherArtifact
import tv.cleanyour.core.model.Op
import tv.cleanyour.core.model.PackageName
import tv.cleanyour.core.model.PackageState
import tv.cleanyour.core.model.SettingKey
import tv.cleanyour.core.model.Sha256
import tv.cleanyour.core.planner.PlanKind
import tv.cleanyour.core.planner.PlanRequest
import tv.cleanyour.core.planner.PlanResult
import tv.cleanyour.core.trust.InterceptorPin
import tv.cleanyour.testing.fixtures.Samples
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.time.Duration.Companion.seconds

// RFC-HOME-BUTTON-1: a Fire TV is offered the Home button, sees the plan first, and after it runs the
// screen says it is on, with the new home screen recorded for the TV.
@OptIn(ExperimentalCoroutinesApi::class)
class HomeButtonMachineTest {
    private val sha = Sha256("c".repeat(64))
    private val interceptor = LauncherArtifact(PackageName("tv.cleanyour.homeinterceptor"), 1, "0.1", sha, Sha256("d".repeat(64)),
        BlobRef(sha, 16_852, "bundled:cleanyourtv-interceptor.apk"))
    private val pin = object : InterceptorPin { override fun bundled() = interceptor }
    private val amazonHome = PackageName("com.amazon.tv.launcher")

    private fun fireSnapshot(at: Long) = Samples.snapshot(
        packages = Samples.miTvPackages() + (amazonHome to PackageState(EnabledState.ENABLED, false, 1, null, false, false, null, true)),
        takenAtMs = at,
    )

    @Test fun aFireTvIsOfferedThePreviewThenTheWriteAndEndsOn() = runTest(timeout = 30.seconds) {
        val h = Harness()
        val tv = h.knownTv().copy(launcher = null).also { h.tvs.upsert(it) }
        h.snapshots.save(fireSnapshot(Samples.NOW_MS + 1))
        h.prober.snapshotFor = { fireSnapshot(Samples.NOW_MS + 5) }
        val launcher = Samples.launcherArtifact()
        val homePlan = h.plan(listOf(Op.InstallStream(launcher.blob, launcher.sha256, launcher.pkg, 1, launcher.signer),
            Op.SettingsPut(SettingKey.ACCESSIBILITY_ENABLED, "1")), kind = PlanKind.HOME_BUTTON, id = "01FAKEHOMEB000000000000001")
        val previous = h.planner.respond
        h.planner.respond = { r, s -> if (r is PlanRequest.UseHomeButton) PlanResult.Ok(homePlan) else previous(r, s) }
        val m = HomeScreenMachine(h.manageDeps(interceptorPin = pin), backgroundScope, tv.id)
        settle()
        assertEquals(HomeButton.OFFER, m.state.value.homeButton)

        m.dispatch(HomeScreenIntent.PreviewHomeButton); settle()
        val preview = assertNotNull(m.state.value.homeButtonPreview)
        assertEquals(homePlan, preview.plan)
        assertEquals(false, preview.off)

        m.effects.test {
            m.dispatch(HomeScreenIntent.UseHomeButton); settle()
            assertEquals(SnackKind.HOME_BUTTON_ON, assertIs<ManageEffect.Snackbar>(drain().single()).kind)
        }
        val request = h.planner.requests.filterIsInstance<PlanRequest.UseHomeButton>().last()
        assertEquals(interceptor, request.interceptor)
        assertNull(m.state.value.homeButtonPreview)
        assertEquals(HomeButton.ON, m.state.value.homeButton)
        assertNotNull(h.tvs.tvs.value.single { it.id == tv.id }.launcher, "the new home screen is recorded for the TV")
    }

    @Test fun anotherTvOrABuildWithoutTheServiceIsNotOffered() = runTest(timeout = 30.seconds) {
        val h = Harness()
        val tv = h.knownTv().also { h.tvs.upsert(it) }
        h.snapshots.save(Samples.snapshot(takenAtMs = Samples.NOW_MS + 1))
        assertNull(HomeScreenMachine(h.manageDeps(interceptorPin = pin), backgroundScope, tv.id).also { settle() }.state.value.homeButton)
        h.snapshots.save(fireSnapshot(Samples.NOW_MS + 2))
        assertNull(HomeScreenMachine(h.manageDeps(), backgroundScope, tv.id).also { settle() }.state.value.homeButton)
    }
}
