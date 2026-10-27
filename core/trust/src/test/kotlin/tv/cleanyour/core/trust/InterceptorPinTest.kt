package tv.cleanyour.core.trust

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test
import tv.cleanyour.core.model.BlobRef
import tv.cleanyour.core.model.PackageName
import tv.cleanyour.core.model.Sha256
import tv.cleanyour.core.store.BlobStore
import java.io.File
import java.io.InputStream
import java.security.MessageDigest

// RFC-CURTAIN-1: the bundled TV curtain, pinned like the launcher and signed with the same key.
// The bundled Fire TV Home interceptor, pinned like the curtain but signed with this fork's own key.
class InterceptorPinTest {
    private val apk = File(Repo.bundled, PinnedInterceptor.ASSET_NAME)

    @Test fun bundledApkMatchesThePin() {
        assertEquals(emptyList<String>(), PinCheck.problems(PinCheck.interceptor, apk))
    }

    @Test fun aModifiedApkFailsTheCheck() {
        val tmp = File.createTempFile("interceptor", ".apk").apply { deleteOnExit() }
        tmp.writeBytes(apk.readBytes().also { it[it.size / 2] = (it[it.size / 2].toInt() xor 1).toByte() })
        val problems = PinCheck.problems(PinCheck.interceptor, tmp)
        assertTrue(problems.toString(), problems.any { it.startsWith("sha256") })
        // The curtain's bytes are not the interceptor.
        val curtain = PinCheck.problems(PinCheck.interceptor, File(Repo.bundled, PinnedCurtain.ASSET_NAME))
        assertTrue(curtain.toString(), curtain.any { it.startsWith("sha256") })
    }

    @Test fun theInterceptorHasItsOwnSignerAndStaysSmall() {
        assertNotEquals(PinnedLauncher.SIGNER_SHA256, PinnedInterceptor.SIGNER_SHA256)
        assertEquals("tv.cleanyour.homeinterceptor", PinnedInterceptor.PACKAGE)
        assertEquals("${PinnedInterceptor.PACKAGE}/.HomeService", PinnedInterceptor.SERVICE)
        assertTrue(PinnedInterceptor.SIZE < 200L * 1024)
    }

    @Test fun bundledInterceptorPinServesThePinnedBlob() {
        val artifact = BundledInterceptorPin(OneBlob(PinnedInterceptor.ASSET_NAME, apk.readBytes())).bundled()
        assertEquals(PackageName(PinnedInterceptor.PACKAGE), artifact.pkg)
        assertEquals(PinnedInterceptor.VERSION_CODE, artifact.versionCode)
        assertEquals(Sha256(PinnedInterceptor.SHA256), artifact.sha256)
        assertEquals(Sha256(PinnedInterceptor.SIGNER_SHA256), artifact.signer)
        assertEquals(artifact.sha256, artifact.blob.sha256)
    }

    @Test fun bundledInterceptorPinRefusesASwappedAsset() {
        assertThrows(IllegalStateException::class.java) { BundledInterceptorPin(OneBlob(PinnedInterceptor.ASSET_NAME, "not the interceptor".toByteArray())).bundled() }
        val launcherBytes = File(Repo.bundled, PinnedLauncher.ASSET_NAME).readBytes()
        assertThrows(IllegalStateException::class.java) { BundledInterceptorPin(OneBlob(PinnedInterceptor.ASSET_NAME, launcherBytes)).bundled() }
    }

    private class OneBlob(private val name: String, private val bytes: ByteArray) : BlobStore {
        private val ref = BlobRef(Sha256(MessageDigest.getInstance("SHA-256").digest(bytes).joinToString("") { "%02x".format(it) }), bytes.size.toLong(), "mem:$name")
        override suspend fun put(sha256: Sha256, source: InputStream, expectedSize: Long): BlobRef = error("read only")
        override fun get(sha256: Sha256): BlobRef? = ref.takeIf { it.sha256 == sha256 }
        override suspend fun delete(sha256: Sha256) = Unit
        override fun bundled(name: String): BlobRef = if (name == this.name) ref else error("no $name")
    }
}
