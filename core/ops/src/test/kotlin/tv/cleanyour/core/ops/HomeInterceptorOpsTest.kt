package tv.cleanyour.core.ops

import tv.cleanyour.core.model.BlobRef
import tv.cleanyour.core.model.Op
import tv.cleanyour.core.model.PackageName
import tv.cleanyour.core.model.Prior
import tv.cleanyour.core.model.SettingKey
import tv.cleanyour.core.model.Sha256
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull
import kotlin.test.assertTrue

// The Fire TV Home button needs no op of its own: the interceptor installs like the launcher and the
// accessibility service is switched on with the two secure settings the planner already writes. This
// pins that those ops render, undo and verify the way the Home button flow relies on.
class HomeInterceptorOpsTest {
    private val r = ShellRenderer()
    private val pkg = PackageName("tv.cleanyour.homeinterceptor")
    private val service = "tv.cleanyour.homeinterceptor/.HomeService"
    private val sha = Sha256("a".repeat(64))
    private val signer = Sha256("b".repeat(64))
    private val install = Op.InstallStream(BlobRef(sha, 16_852, "bundled:cleanyourtv-interceptor.apk"), sha, pkg, 1, signer)

    @Test fun theInterceptorStreamsInLikeTheLauncher() {
        val rendered = r.render(install)
        assertTrue(rendered.lines.isEmpty())
        assertEquals(16_852L, (rendered.transfer as Transfer.StreamInstall).size)
    }

    @Test fun anInstallThatWasNotThereIsUninstalledOnUndoAndAnUpgradeIsLeft() {
        assertEquals(Op.Uninstall(pkg), r.inverse(install, Prior(present = false)))
        assertNull(r.inverse(install, Prior(present = true)))
    }

    @Test fun theServiceIsSwitchedOnKeepingTheOnesAlreadyOn() {
        val list = "com.example.talkback/.Service:$service"
        assertEquals(
            "'settings' 'put' 'secure' 'enabled_accessibility_services' '$list'",
            r.render(Op.SettingsPut(SettingKey.ENABLED_ACCESSIBILITY, list)).lines.single().text,
        )
        assertEquals(
            "'settings' 'put' 'secure' 'accessibility_enabled' '1'",
            r.render(Op.SettingsPut(SettingKey.ACCESSIBILITY_ENABLED, "1")).lines.single().text,
        )
    }

    @Test fun undoPutsTheEarlierListBackOrDeletesTheKeyWhenThereWasNone() {
        val put = Op.SettingsPut(SettingKey.ENABLED_ACCESSIBILITY, service)
        assertEquals(Op.SettingsPut(SettingKey.ENABLED_ACCESSIBILITY, "com.example/.S"), r.inverse(put, Prior(settingValue = "com.example/.S")))
        assertEquals(Op.SettingsPut(SettingKey.ENABLED_ACCESSIBILITY, null), r.inverse(put, Prior(settingValue = null)))
    }

    @Test fun aListThatIsNotComponentsIsRefused() {
        assertFailsWith<RenderRefused> { r.render(Op.SettingsPut(SettingKey.ENABLED_ACCESSIBILITY, "$service; reboot")) }
    }

    @Test fun theSettingIsVerifiedByReadingItBack() {
        val put = Op.SettingsPut(SettingKey.ENABLED_ACCESSIBILITY, service)
        assertEquals(VerifyResult.Ok, r.check(put, "enabled_accessibility_services=$service\n", null))
        assertTrue(r.check(put, "enabled_accessibility_services=other/.S\n", null) is VerifyResult.Mismatch)
    }
}
