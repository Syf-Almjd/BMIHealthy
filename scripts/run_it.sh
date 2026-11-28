#!/bin/bash
# Runs the integration test on the emulator. A background loop screencaps every 3s,
# but only while the app under test owns the window focus, and logs the focus line.
FILE=${1:-integration_test/history_test.dart}; SH=${2:-shots}
mkdir -p $SH
flutter test $FILE -d emulator-5554 --dart-define=USE_TEST_ADS=true > it_$(basename $SH).log 2>&1 &
PID=$!
(
  n=0
  while kill -0 $PID 2>/dev/null && [ $n -lt 160 ]; do
    F=$(adb shell dumpsys window 2>/dev/null | grep -m1 mCurrentFocus | tr -d '\r')
    if echo "$F" | grep -q "com.mjd.bmihealthy"; then
      n=$((n+1))
      adb exec-out screencap -p > "$SH/app_$(printf %02d $n).png"
      echo "app_$(printf %02d $n) $(date +%T) markers=$(grep -c 'SHOT:' it_$(basename $SH).log) focus=$F" >> $SH/focus.log
    else
      echo "nofocus $(date +%T) $F" >> $SH/focus.log
    fi
    sleep 3
  done
) &
CAP=$!
wait $PID
RC=$?
sleep 1; kill $CAP 2>/dev/null
echo "test exit code: $RC"
tail -40 it_$(basename $SH).log
adb logcat -d 2>/dev/null | grep -iE "gads|Ads:|AdRequest|AdLoader" | tail -25 | cut -c1-220 | sed "s/^/ADLOG: /"
for f in $(ls $SH/app_*.png 2>/dev/null | while read x; do echo "$(md5sum < $x | cut -c1-8) $x"; done | sort -k1,1 -u | awk '{print $2}' | sort | tail -30); do echo "B64_BEGIN $f"; base64 -w0 "$f"; echo; echo "B64_END $f"; done
echo "captured: $(ls $SH | grep -c "^app_")"
if [ $RC -ne 0 ]; then
  grep -E "Expected|Actual|EXCEPTION|Exception|Bad state|Failed|failed|find|Which:|SHOT:|STEP:|AD_WIDGET|The following|overflow" it_$(basename $SH).log | head -30 | cut -c1-220 | while IFS= read -r l; do echo "::error::$l"; done
fi
exit $RC
