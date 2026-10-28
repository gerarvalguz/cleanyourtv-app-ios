package tv.cleanyour.homeinterceptor;

import android.accessibilityservice.AccessibilityService;
import android.content.ComponentName;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.view.KeyEvent;
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
    // A short press of the remote's Home button just ended: the Amazon home that follows is the answer to
    // it, not the first step of opening Settings, so it is redirected at once (no 700 ms of Amazon's home).
    // A long press (the quick menu, which can lead to Settings) is not a short press. shortcut: if the
    // service never receives KEYCODE_HOME, nothing changes and the wait stays as it was.
    static final long SHORT_PRESS_MS = 400;
    static final long SHORT_HOME_WINDOW_MS = 1000;
    private long homeDownAt;
    private long shortHomeAt = -SHORT_HOME_WINDOW_MS;

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
        boolean answersHome = SystemClock.uptimeMillis() - shortHomeAt < SHORT_HOME_WINDOW_MS;
        if (name.contains("HomeActivity")) handler.postDelayed(redirect, fromSettings || answersHome ? 0 : WAIT_MS);
        else fromSettings = name.contains("Settings");
    }

    // Only watches the key; it is never taken, so Home reaches Fire OS exactly as before.
    @Override protected boolean onKeyEvent(KeyEvent e) {
        if (e.getKeyCode() == KeyEvent.KEYCODE_HOME) {
            long now = SystemClock.uptimeMillis();
            if (e.getAction() == KeyEvent.ACTION_DOWN && e.getRepeatCount() == 0) homeDownAt = now;
            else if (e.getAction() == KeyEvent.ACTION_UP && now - homeDownAt < SHORT_PRESS_MS) shortHomeAt = now;
        }
        return false;
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
