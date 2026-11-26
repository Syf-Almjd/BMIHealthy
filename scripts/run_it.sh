#!/bin/bash
# Runs the integration test on the emulator. A background loop screencaps every 3s,
# but only while the app under test owns the window focus, and logs the focus line.
mkdir -p shots
flutter test integration_test/history_test.dart -d emulator-5554 --dart-define=USE_TEST_ADS=true > it.log 2>&1 &
PID=$!
(
  n=0
  while kill -0 $PID 2>/dev/null && [ $n -lt 60 ]; do
    F=$(adb shell dumpsys window 2>/dev/null | grep -m1 mCurrentFocus | tr -d '\r')
    if echo "$F" | grep -q "com.mjd.bmihealthy"; then
      n=$((n+1))
      adb exec-out screencap -p > "shots/app_$(printf %02d $n).png"
      echo "app_$(printf %02d $n) $(date +%T) markers=$(grep -c 'SHOT:' it.log) focus=$F" >> shots/focus.log
    else
      echo "nofocus $(date +%T) $F" >> shots/focus.log
    fi
    sleep 3
  done
) &
CAP=$!
wait $PID
RC=$?
sleep 1; kill $CAP 2>/dev/null
echo "test exit code: $RC"
tail -40 it.log
adb logcat -d 2>/dev/null | grep -iE "gads|Ads:|AdRequest|AdLoader" | tail -25 | cut -c1-220 | sed "s/^/ADLOG: /"
echo "captured: $(ls shots | grep -c '^app_')"
if [ $RC -ne 0 ]; then
  grep -E "Expected|Actual|EXCEPTION|Exception|Bad state|Failed|failed|find|Which:|SHOT:|AD_WIDGET|The following|overflow" it.log | head -12 | cut -c1-220 | while IFS= read -r l; do echo "::error::$l"; done
fi
exit $RC
