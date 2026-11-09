---
name: review-recording
description: Transcribe and review a meeting, demo, interview, or screen recording on this Mac, fully offline with whisper.cpp and ffmpeg, then pull out decisions, commitments, stumbles, and follow-ups with timestamps and stills. Use when the user asks to transcribe, review, watch, summarize, or take notes from a recording or video file (.mp4, .mov, .m4a, .mkv, .webm, .wav, Zoom, Meet, or OBS recordings, usually in ~/Downloads), to run whisper or speech to text on a file, or to grab screenshots or snippets from a recording. Not for a transcript the user already pasted, for converting or compressing video, or for adding speech recognition to an app.
---

# review-recording

The pipeline is two scripts. Whisper's failure modes on long audio are silent (hallucination loops look like text), so the scripts carry the flags that avoid them and the checks that catch them; don't hand-roll the commands.

## Steps

1. **Size it.** `ffprobe -v error -show_entries format=duration -of csv=p=0 "<file>"`. Transcription runs about 8.5 s per minute of audio on the M3 Pro (2 h 51 min took 24 min). Tell the user the estimate.

2. **Pick the output dir:** the session scratchpad, never a repo working tree. Recordings name people; a review written into a public repo leaks them.

3. **Transcribe**, in the background for anything over 10 minutes:

   ```bash
   ~/.claude/skills/review-recording/scripts/transcribe.sh "<file>" "<outdir>"
   ```

   It extracts 16 kHz mono audio, downloads the models to `~/.cache/whisper-cpp/` if missing (1.6 GB, once), runs `whisper-cli` with `--vad --max-context 0` and no `--prompt`, and writes `paragraphs.txt`: ~30 s blocks prefixed `[hh:mm:ss]`. If `ffmpeg` or `whisper-cli` is missing, it exits 2; ask before `brew install`.

   Never add `--prompt` with vocabulary or names. It made large-v3-turbo repeat the prompt for 30 minutes of output. Fix misheard terms when reading instead.

4. **While it runs, map the video:**

   ```bash
   ~/.claude/skills/review-recording/scripts/frames.sh sheet "<file>" "<outdir>/frames"
   ```

   Read `sheet.jpg` (6x6, row-major; the script prints which minute each tile is) to find the phases: slides, screen share, which app, gaps. Homebrew ffmpeg has no `drawtext`, so don't try to stamp timestamps on images.

5. **Check before reading.** The script prints the most repeated segments. A count above about 5 is a loop: re-run that range alone (`whisper-cli ... --offset-t <ms> --duration <ms>`) and splice it, or flag the range as untranscribed.

6. **Read `paragraphs.txt` in full**, in chunks with `Read` offset and limit. Note timestamps for: decisions, things promised to someone ("I'll get back to you"), questions left unanswered, requested changes, and stumbles (errors, "wait", "that's not right", long silences, restarts).

7. **Look at the stumbles.** For each moment worth seeing, pull stills and Read them:

   ```bash
   ~/.claude/skills/review-recording/scripts/frames.sh at "<file>" "<outdir>/frames" 01:17:40 01:22:30
   ```

   The screen often explains what the audio doesn't (wrong user logged in, error toast, wrong record open).

8. **Write the review** as markdown in the output dir, or where the user says. Sections, each omitted when empty:
   - Owed to others: item, who it is owed to, timestamp, quoted promise.
   - Requested changes: what, who asked, timestamp.
   - Decisions and statements made on the record.
   - Stumbles: timestamp, what happened, minutes lost, cause from the still.
   - Timing per phase from the contact sheet.

   Whisper has no speaker labels. Every attribution is inferred from context: mark it "(inferred)" unless the speaker names themself or is addressed by name. Quote with timestamps so the user can check.

9. **Report** the review path, the transcript path, and the output dir's size (`du -sh`); the WAV is about 115 MB per hour. Leave the models in `~/.cache/whisper-cpp/`.

Done when: the repetition check is clean or the bad ranges are flagged, the whole transcript was read, each stumble cites a still you looked at, and every attribution is either named in the audio or marked inferred.
