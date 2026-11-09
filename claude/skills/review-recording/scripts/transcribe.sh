#!/usr/bin/env bash
# Usage: transcribe.sh <recording> <outdir>
# Writes <outdir>/audio.wav, transcript.srt, transcript.txt, and paragraphs.txt
# (~30 s blocks, each prefixed [hh:mm:ss]), then prints a repetition check.
set -euo pipefail
in=$1; out=$2
models=${WHISPER_MODELS:-$HOME/.cache/whisper-cpp}
model=$models/ggml-large-v3-turbo.bin
vad=$models/ggml-silero-v5.1.2.bin

for tool in ffmpeg whisper-cli; do
  command -v "$tool" >/dev/null || { echo "missing $tool: ask the user before running 'brew install ${tool/whisper-cli/whisper-cpp}'" >&2; exit 2; }
done
mkdir -p "$out" "$models"
[[ -s $model ]] || curl --location --fail --silent --show-error --output "$model" \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin
[[ -s $vad ]] || curl --location --fail --silent --show-error --output "$vad" \
  https://huggingface.co/ggml-org/whisper-vad/resolve/main/ggml-silero-v5.1.2.bin

ffmpeg -hide_banner -loglevel error -y -i "$in" -vn -ac 1 -ar 16000 -c:a pcm_s16le "$out/audio.wav"

# No --prompt: a vocabulary prompt makes large-v3-turbo loop on the prompt text.
# --vad skips silence and --max-context 0 stops one hallucination seeding the next window.
whisper-cli --model "$model" --file "$out/audio.wav" --language "${WHISPER_LANG:-en}" \
  --threads "$(sysctl -n hw.perflevel0.physicalcpu 2>/dev/null || echo 8)" \
  --vad --vad-model "$vad" --max-context 0 \
  --output-srt --output-txt --output-file "$out/transcript" > "$out/whisper.log" 2>&1
grep 'total time' "$out/whisper.log" || true

awk 'BEGIN{RS="";FS="\n"}
  { split($2,a," --> "); t=substr(a[1],1,8); split(t,h,":"); s=h[1]*3600+h[2]*60+h[3]
    txt=""; for(i=3;i<=NF;i++) txt=txt" "$i
    if (NR==1 || s-last>=30) { if (buf!="") print buf; buf="["t"]"txt; last=s } else buf=buf txt }
  END{print buf}' "$out/transcript.srt" > "$out/paragraphs.txt"

wc -l "$out/paragraphs.txt"
echo "most repeated segments (a count above ~5 means a hallucination loop):"
awk 'BEGIN{RS="";FS="\n"} {print $3}' "$out/transcript.srt" | sort | uniq -c | sort -rn | head -5
