#!/bin/sh
# Builds firetv-home-interceptor.apk with the SDK tools only (no Gradle).
# Signed with the fork key in $KEYS (default ~/.cleanyourtv-fork-keys: interceptor.jks and interceptor.pass,
# never in the repo); without it, with the debug key, which no bundled pin accepts.
set -e
cd "$(dirname "$0")"
SDK=${ANDROID_HOME:-$HOME/Library/Android/sdk}
BT=$SDK/build-tools/35.0.0
JAR=$SDK/platforms/android-34/android.jar
rm -rf out && mkdir -p out/classes out/res
javac -source 8 -target 8 -Xlint:-options -bootclasspath "$JAR" -d out/classes src/tv/cleanyour/homeinterceptor/*.java
"$BT/d8" --lib "$JAR" --min-api 26 --output out out/classes/tv/cleanyour/homeinterceptor/*.class
"$BT/aapt2" compile --dir res -o out/res
"$BT/aapt2" link -I "$JAR" --manifest AndroidManifest.xml --min-sdk-version 26 --target-sdk-version 30 -o out/base.apk out/res/*.flat
(cd out && touch -t 198001010000 classes.dex && zip -X -q base.apk classes.dex)
"$BT/zipalign" -f 4 out/base.apk out/aligned.apk
KEYS=${KEYS:-$HOME/.cleanyourtv-fork-keys}
if [ -f "$KEYS/interceptor.jks" ]; then
  "$BT/apksigner" sign --ks "$KEYS/interceptor.jks" --ks-pass "file:$KEYS/interceptor.pass" --out firetv-home-interceptor.apk out/aligned.apk
else
  "$BT/apksigner" sign --ks "$HOME/.android/debug.keystore" --ks-pass pass:android --out firetv-home-interceptor.apk out/aligned.apk
fi
echo built firetv-home-interceptor.apk
