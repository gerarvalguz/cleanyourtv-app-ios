package tv.cleanyour.core.flows

import tv.cleanyour.core.model.PackageName
import tv.cleanyour.core.spec.BundledThemeSource
import tv.cleanyour.core.spec.StyleId
import tv.cleanyour.testing.fixtures.FakeClock
import tv.cleanyour.testing.fixtures.Samples
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

// The greeting name rides along with every look the phone sends: a look is built from scratch, so
// without it a new look would drop the name the person typed.
class GreetingNameTest {
    private val looks = BundledThemeSource()
    private val drafts = LookDrafts(looks, looks, ConfigEncoder.Codec, FakeClock(Samples.NOW_MS))
    private val apps = List(4) { AppChoice(PackageName("com.example.app$it"), "App $it") }
    private val ctx = LookContext(apps, tv = LookTv(8L, 2048, true))
    private val draft = drafts.open(HomeChoice(emptyList(), null, picture = "mist", columns = 5, style = StyleId.CLASSIC.id), ctx)

    @Test fun cleanKeepsOneShortLine() {
        assertEquals("Ana", GreetingName.clean("  Ana\n"))
        assertEquals("", GreetingName.clean(" \t\n"))
        assertEquals(40, GreetingName.clean("x".repeat(100)).length)
    }

    @Test fun theNameGoesIntoTheDocTheSendPushes() {
        val named = drafts.edit(draft, LookEdit.SetGreetingName(" Ana "), ctx)
        assertEquals("Ana", named.greetingName)
        val sendCtx = ctx.copy(greetingName = named.greetingName)
        assertEquals("Ana", drafts.docOf(named, apps.map { it.pkg }, true, sendCtx).first.greetingName)
        assertNull(drafts.docOf(draft, apps.map { it.pkg }, true, ctx).first.greetingName, "no name, no key")
    }

    @Test fun emptyingTheNameTakesTheKeyOut() {
        val named = drafts.edit(draft, LookEdit.SetGreetingName("Ana"), ctx)
        val cleared = drafts.edit(named, LookEdit.SetGreetingName(""), ctx.copy(greetingName = "Ana"))
        assertEquals("", cleared.greetingName)
        assertNull(drafts.docOf(cleared, apps.map { it.pkg }, true, ctx.copy(greetingName = cleared.greetingName)).first.greetingName)
    }
}
