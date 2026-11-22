#!/bin/bash
# Recorded App Store preview 886x1920: real simulator take (src/take.mov, from src/take.sh)
# framed under per-scene captions, edge-tts narration, end card. H.264 30fps + AAC stereo 48k.
set -euo pipefail
cd "$(dirname "$0")"
XF=0.25; CF=0.3; END=2.2
# take.mov cut: [0,4.75] + [7.0,26.2] (drops the ad-gate prompt between them)
A0=0; A1=4.75; B0=7.0; B1=26.2
REC=$(echo "($A1-$A0)+($B1-$B0)-$XF" | bc -l)              # 23.70
BOUNDS=(0 4.6 8.9 12.5 17.15 $REC)                          # caption scene edges
NARR=(0.4 4.7 8.95 12.5 17.2)                               # narration starts
inputs=(-i src/take.mov -i build/mask.png); f=""
f+="[0:v]fps=30,split[r1][r2];"
f+="[r1]trim=$A0:$A1,setpts=PTS-STARTPTS[ra];[r2]trim=$B0:$B1,setpts=PTS-STARTPTS[rb];"
f+="[ra][rb]xfade=transition=fade:duration=$XF:offset=$(echo "$A1-$A0-$XF"|bc -l),"
f+="scale=700:1520:force_original_aspect_ratio=increase,crop=700:1520,format=rgba[rs];"
f+="[1:v]format=gray,loop=-1:1,trim=0:$REC[m];[rs][m]alphamerge[phone];"
# caption backgrounds, crossfaded at scene edges
for i in 1 2 3 4 5; do
  s=${BOUNDS[$((i-1))]}; e=${BOUNDS[$i]}
  d=$(echo "$e-$s+$CF" | bc -l)
  inputs+=(-loop 1 -t "$d" -framerate 30 -i build/cap$i.png)
  f+="[$((i+1)):v]format=yuv420p,setsar=1[c$i];"; done
prev=c1; acc=$(echo "${BOUNDS[1]}-${BOUNDS[0]}+$CF" | bc -l)
for i in 2 3 4 5; do
  off=$(echo "${BOUNDS[$((i-1))]}-$CF/2" | bc -l)
  f+="[$prev][c$i]xfade=transition=fade:duration=$CF:offset=$off[bg$i];"; prev=bg$i; done
f+="[$prev]trim=0:$REC,setpts=PTS-STARTPTS[bg];"
f+="[bg][phone]overlay=93:360:shortest=1,format=yuv420p[main];"
inputs+=(-loop 1 -t $END -framerate 30 -i endcard.png)
f+="[7:v]format=yuv420p,setsar=1[end];"
f+="[main][end]xfade=transition=fade:duration=$CF:offset=$(echo "$REC-$CF"|bc -l)[vout];"
TOTAL=$(echo "$REC-$CF+$END" | bc -l)
mix=""
for k in 0 1 2 3 4; do
  n=$(printf '%02d' $((k+1))); inputs+=(-i audio/$n.mp3)
  ms=$(printf '%.0f' "$(echo "${NARR[$k]}*1000" | bc -l)")
  f+="[$((8+k)):a]aresample=48000,adelay=${ms}|${ms}[a$k];"; mix+="[a$k]"; done
f+="${mix}amix=inputs=5:normalize=0,pan=stereo|c0=c0|c1=c0,apad,atrim=0:$TOTAL[aout]"
ffmpeg -y -loglevel error "${inputs[@]}" -filter_complex "$f" -map "[vout]" -map "[aout]" \
  -c:v libx264 -profile:v high -level 4.0 -pix_fmt yuv420p -r 30 -b:v 10M -maxrate 12M -bufsize 20M \
  -c:a aac -b:a 256k -ar 48000 -ac 2 -movflags +faststart -t "$TOTAL" preview_recorded_886x1920.mp4
echo "total=${TOTAL}s"
