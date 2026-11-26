#!/bin/bash
# Runs the integration test on the emulator and takes screenshots at markers.
mkdir -p shots
flutter test integration_test/history_test.dart -d emulator-5554 > it.log 2>&1 &
PID=$!
for s in home history_empty history_populated; do
  for i in $(seq 1 600); do
    grep -q "SHOT:$s" it.log && break
    kill -0 $PID 2>/dev/null || break
    sleep 1
  done
  sleep 2
  adb exec-out screencap -p > "shots/$s.png"
done
wait $PID
RC=$?
echo "test exit code: $RC"
tail -40 it.log
if [ $RC -ne 0 ]; then
  grep -E "Expected|Actual|EXCEPTION|Exception|Bad state|Failed|failed|find|Which:|SHOT:|AD_WIDGET|The following|overflow" it.log | head -12 | cut -c1-220 | while IFS= read -r l; do echo "::error::$l"; done
fi
exit $RC
