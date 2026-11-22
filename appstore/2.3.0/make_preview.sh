#!/bin/bash
# App Store preview 886x1920 (iPhone 6.9"/6.7"), 30fps H.264 + AAC stereo 48k.
set -euo pipefail
cd "$(dirname "$0")"
FR=../../fastlane/screenshots/ko
IMGS=("$FR/iPhone69-01_home.png" "$FR/iPhone69-02_random.png" "$FR/iPhone69-03_detail.png" "$FR/iPhone69-04_list.png" "$FR/iPhone69-05_share.png" endcard.png)
PAD=0.9; XF=0.4; LEAD=0.35; END=2.2
durs=(); for n in 01 02 03 04 05; do
  a=$(ffprobe -v error -show_entries format=duration -of csv=p=0 audio/$n.mp3)
  durs+=("$(echo "$a + $LEAD + $PAD" | bc -l)"); done
durs+=("$END")
inputs=(); filt=""; i=0
for img in "${IMGS[@]}"; do
  d=${durs[$i]}; frames=$(printf '%.0f' "$(echo "$d*30+1" | bc -l)")
  inputs+=(-loop 1 -t "$d" -i "$img")
  # slow push-in (1.00 -> 1.05) on a 2x upscaled source for smooth subpixel motion
  filt+="[$i:v]scale=1772:3840:force_original_aspect_ratio=decrease,pad=1772:3840:(ow-iw)/2:(oh-ih)/2:color=0x140A22,"
  filt+="zoompan=z='1+0.05*on/$frames':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=$frames:s=886x1920:fps=30,setsar=1,format=yuv420p[v$i];"
  i=$((i+1)); done
# chain xfades
prev="v0"; off=0; starts=(0)
for ((k=1;k<${#IMGS[@]};k++)); do
  off=$(echo "$off + ${durs[$((k-1))]} - $XF" | bc -l); starts+=("$off")
  filt+="[$prev][v$k]xfade=transition=fade:duration=$XF:offset=$off[x$k];"; prev="x$k"; done
# narration placed at each scene start + LEAD
ai=$i; amix=""
for ((k=0;k<5;k++)); do
  n=$(printf '%02d' $((k+1))); inputs+=(-i "audio/$n.mp3")
  ms=$(printf '%.0f' "$(echo "(${starts[$k]} + $LEAD)*1000" | bc -l)")
  filt+="[$((ai+k)):a]aresample=48000,adelay=${ms}|${ms}[a$k];"; amix+="[a$k]"; done
total=$(echo "$off + $END" | bc -l)
filt+="${amix}amix=inputs=5:normalize=0,pan=stereo|c0=c0|c1=c0,apad,atrim=0:$total,afade=t=out:st=$(echo "$total-0.4"|bc -l):d=0.4[aout]"
ffmpeg -y -loglevel error "${inputs[@]}" -filter_complex "$filt" -map "[$prev]" -map "[aout]" \
  -c:v libx264 -profile:v high -level 4.0 -pix_fmt yuv420p -r 30 -b:v 10M -maxrate 12M -bufsize 20M \
  -c:a aac -b:a 256k -ar 48000 -ac 2 -movflags +faststart -t "$total" preview_886x1920.mp4
echo "total=${total}s"
