package tv.cleanyour.homeinterceptor;

import android.accessibilityservice.AccessibilityService;
import android.content.ComponentName;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.view.accessibility.AccessibilityEvent;

// Amazon's home screen came to the front: open ours. Fire OS ignores set-home-activity, so this
// reacts to the window instead of owning Home.
public class HomeService extends AccessibilityService {
    static final ComponentName REAL_HOME = new ComponentName("com.gathin.tvhome", "com.gathin.tvhome.MainActivity");
    static final long DEBOUNCE_MS = 1500;
    static final long WAIT_MS = 700;
    // shortcut: one process-wide pause, set by ProbeActivity's Back so Amazon's home stays reachable.
    static volatile long pausedUntil;
    private long lastRedirect;
    // The last Amazon window was a Settings screen, so Home now is the way back out of Settings and
    // can be redirected at once; without it Home may be the first step of opening Settings.
    private boolean fromSettings;

    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Runnable redirect = new Runnable() { public void run() { open(); } };

    // Amazon's Settings open HomeActivity first and their own screen ~200 ms later (same package), so
    // the redirect waits and a later non-Home window of that package cancels it. Coming back out of
    // Settings there is no screen after Home, so waiting would only show Amazon's home for 700 ms.
    @Override public void onAccessibilityEvent(AccessibilityEvent e) {
        CharSequence cls = e.getClassName();
        if (cls == null) return;
        handler.removeCallbacks(redirect);
        String name = cls.toString();
        if (name.contains("HomeActivity")) handler.postDelayed(redirect, fromSettings ? 0 : WAIT_MS);
        else fromSettings = name.contains("Settings");
    }

    private void open() {
        fromSettings = false;
        long now = SystemClock.uptimeMillis();
        if (now < pausedUntil || now - lastRedirect < DEBOUNCE_MS) return;
        lastRedirect = now;
        Intent i = new Intent(Intent.ACTION_MAIN).setComponent(REAL_HOME).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        try { startActivity(i); } catch (Exception notInstalled) {
            startActivity(new Intent(this, ProbeActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
        }
    }

    @Override public void onInterrupt() {}
}
