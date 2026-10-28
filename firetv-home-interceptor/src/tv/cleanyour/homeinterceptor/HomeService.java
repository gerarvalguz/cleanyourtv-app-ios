package tv.cleanyour.homeinterceptor;

import android.accessibilityservice.AccessibilityService;
import android.content.ComponentName;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.view.accessibility.AccessibilityEvent;

// Amazon's home screen came to the front: open ours. Fire OS ignores set-home-activity, so this
// reacts to the window instead of owning Home. Fire OS never hands the Home key to an accessibility
// service (the other remote keys do arrive), so Home is only known by the window it opens.
public class HomeService extends AccessibilityService {
    static final String OURS = "com.gathin.tvhome";
    static final ComponentName REAL_HOME = new ComponentName(OURS, OURS + ".MainActivity");
    static final long DEBOUNCE_MS = 1500;
    static final long WAIT_MS = 700;
    // shortcut: one process-wide pause, set by ProbeActivity's Back so Amazon's home stays reachable.
    static volatile long pausedUntil;
    private long lastRedirect;
    // The last Amazon window was a Settings screen, so Home now is the way back out of Settings and
    // can be redirected at once; without it Home may be the first step of opening Settings.
    private boolean fromSettings;
    // The window that was in front before Amazon's home showed up. Ours in front means Home was pressed
    // on our launcher (its own Settings button opens Amazon's Settings without Amazon's home first), so
    // the redirect needs no wait. Any other window (an app, a pop-up) keeps the wait.
    private String frontBefore = "";
    private boolean pending;

    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Runnable redirect = new Runnable() { public void run() { open(); } };

    // Amazon's Settings opened from elsewhere open HomeActivity first and their own screen ~200 ms later
    // (same package), so that redirect waits and a later non-Home window of that package cancels it.
    // Amazon sends two HomeActivity events a few hundred ms apart for one Home; the second must not
    // restart the wait. Windows of other packages only say who was in front.
    @Override public void onAccessibilityEvent(AccessibilityEvent e) {
        CharSequence cls = e.getClassName(), pkg = e.getPackageName();
        if (cls == null || pkg == null) return;
        String name = cls.toString(), p = pkg.toString();
        if (!p.equals("com.amazon.tv.launcher") && !p.equals("com.amazon.firehomestarter")) {
            frontBefore = p;
            return;
        }
        if (name.contains("HomeActivity")) {
            if (pending) return;
            pending = true;
            handler.postDelayed(redirect, fromSettings || OURS.equals(frontBefore) ? 0 : WAIT_MS);
        } else {
            handler.removeCallbacks(redirect);
            pending = false;
            fromSettings = name.contains("Settings");
        }
        frontBefore = p;
    }

    private void open() {
        fromSettings = false;
        pending = false;
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
