#!/usr/bin/env bash
# Usage:
#   frames.sh sheet <recording> <outdir>          one frame per minute + contact sheet
#   frames.sh at <recording> <outdir> <hh:mm:ss>...  full-width stills at given times
set -euo pipefail
mode=$1 in=$2 out=$3; shift 3
mkdir -p "$out"
case $mode in
sheet)
  # Homebrew ffmpeg has no drawtext, so timestamps live in file names, not on the image.
  ffmpeg -hide_banner -loglevel error -y -i "$in" -vf "fps=1/60,scale=960:-1" -frame_pts 1 -q:v 4 "$out/m%03d.jpg"
  n=$(ls "$out"/m*.jpg | wc -l | tr -d ' ')
  step=$(( (n + 35) / 36 ))
  ffmpeg -hide_banner -loglevel error -y -framerate 1 -pattern_type glob -i "$out/m*.jpg" \
    -vf "select='not(mod(n\,$step))',scale=480:-1,tile=6x6" -frames:v 1 -q:v 3 "$out/sheet.jpg"
  echo "$n minute frames in $out/m<minute>.jpg; $out/sheet.jpg is 6x6, row-major, tile k = minute k*$step"
  ;;
at)
  for t in "$@"; do
    ffmpeg -hide_banner -loglevel error -y -ss "$t" -i "$in" -frames:v 1 -vf scale=1600:-1 -q:v 3 "$out/at-${t//:/}.jpg"
  done
  ls "$out"/at-*.jpg
  ;;
*) echo "mode must be sheet or at" >&2; exit 2 ;;
esac
