#!/bin/bash
# Scripted take: logs action timestamps (seconds since recording start) to take.log
U=${SIM_UDID:-39D7367E-86EA-41EA-8AC9-48F907B48F02}
SP=$(dirname "$0"); OUT=$SP/take.mov; LOG=$SP/take.log
$SP/fresh.sh "${1:?usage: take.sh path/to/App.app}"
xcrun simctl launch $U com.credif.letscheers >/dev/null; sleep 9   # data import + settle
rm -f $OUT; xcrun simctl io $U recordVideo --codec=h264 --force $OUT 2>/dev/null & REC=$!
sleep 1.2; T0=$(python3 -c 'import time;print(time.time())'); : > $LOG
mark(){ python3 -c "import time;print('%.2f $1'%(time.time()-$T0))" >> $LOG; }
tap(){ mark "$3"; idb ui tap --udid $U $1 $2; }
sleep 3.5;  tap 220 226 random
sleep 1.2;  tap 219 830 accept
sleep 2.4;  tap 220 772 reroll
sleep 2.2;  tap 156 836 readmode
sleep 3.6;  tap 42 84 back
sleep 1.4;  tap 115 514 category
sleep 2.4;  tap 130 390 row
sleep 2.4;  mark swipe; idb ui swipe --udid $U 380 450 60 450 --duration 0.3
sleep 2.0;  tap 325 888 share
sleep 3.0;  mark end
kill -INT $REC; wait $REC 2>/dev/null
cat $LOG
