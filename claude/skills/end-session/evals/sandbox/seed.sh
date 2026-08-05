#!/usr/bin/env bash
# Recreate the logtool sandbox repo used by evals.json.
#
# Usage:
#   seed.sh <target-dir>          # clean repo (evals 0 and 2)
#   seed.sh <target-dir> --dirty  # eval 1: uncommitted regex change + untracked scratch.txt
set -euo pipefail

TARGET="${1:?usage: seed.sh <target-dir> [--dirty]}"
HERE="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$TARGET"
cp "$HERE/README.md" "$TARGET/"
mkdir -p "$TARGET/src"
cp "$HERE/src/log_parser.py" "$HERE/src/report.py" "$TARGET/src/"

git -C "$TARGET" init -q -b main
git -C "$TARGET" add -A
git -C "$TARGET" -c user.name=seed -c user.email=seed@example.com \
  commit -qm "initial logtool"

if [[ "${2:-}" == "--dirty" ]]; then
  python3 - "$TARGET/src/log_parser.py" <<'EOF'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
old = r'LINE_RE = re.compile(r"^(?P<ts>\S+) (?P<level>[A-Z]+) (?P<msg>.*)$")'
new = r'LINE_RE = re.compile(r"^(?P<ts>\S+)\s+(?P<level>[A-Z]+):? (?P<msg>.*)$")'
src = p.read_text()
assert old in src, "expected original LINE_RE not found"
p.write_text(src.replace(old, new))
EOF
  printf 'random notes\ngrep ERROR /var/log/app.log | wc -l\n' > "$TARGET/scratch.txt"
fi

git -C "$TARGET" status --short
echo "seeded: $TARGET"
