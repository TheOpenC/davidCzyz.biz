#!/usr/bin/env bash
set -e
shopt -s nullglob

BASEDIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$BASEDIR"
OUTPUT_DIR="$BASEDIR/mp4"
WIDTHS=(768 1200 2000)

mkdir -p "$OUTPUT_DIR"

for src in "$SRC_DIR"/*.gif; do
  [ -f "$src" ] || continue
  base="$(basename "$src" .gif)"

  native_fps=$(ffprobe -v error -select_streams v:0 \
    -show_entries stream=avg_frame_rate \
    -of default=noprint_wrappers=1:nokey=1 "$src")

  for w in "${WIDTHS[@]}"; do
    out="$OUTPUT_DIR/${base}-${w}.mp4"
    echo "→ $out  ($native_fps fps)"

    ffmpeg -y -i "$src" \
      -vf "setpts=PTS-STARTPTS,fps=${native_fps},scale=${w}:-2:flags=lanczos,colormatrix=smpte170m:bt709" \
      -c:v libx264 -preset slow -crf 18 -tune animation \
      -pix_fmt yuv420p -fps_mode cfr \
      -color_primaries bt709 -color_trc bt709 -colorspace bt709 \
      -movflags +faststart -an \
      "$out"
  done
done