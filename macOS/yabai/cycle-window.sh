#!/bin/sh
# Focus the next/previous window in the current space, in a stable order.
#
# yabai's default window order tracks stacking and recency, so it reshuffles
# every time focus changes and cycling never lands where you expect. Window ids
# are assigned at creation and never change, so sorting by id gives a ring that
# stays put: repeated `next` visits every window once and comes back around,
# the way cmd-` does within an app.
set -eu

YABAI=${YABAI:-/opt/homebrew/bin/yabai}
JQ=${JQ:-/opt/homebrew/bin/jq}

case "${1:-next}" in
  next) step=1 ;;
  prev) step=-1 ;;
  *) echo "usage: $(basename "$0") [next|prev]" >&2; exit 2 ;;
esac

target=$("$YABAI" -m query --windows --space | "$JQ" -r --argjson step "$step" '
  [ .[] | select(."is-minimized" == false) ] | sort_by(.id) as $w
  | ($w | length) as $n
  | ($w | map(."has-focus") | index(true)) as $i
  | if $n == 0 then empty
    # Nothing focused in this space (or focus is on an unmanaged window):
    # start the ring rather than doing nothing.
    elif $i == null then $w[0].id
    else $w[ ((($i + $step) % $n) + $n) % $n ].id
    end
')

[ -n "$target" ] && exec "$YABAI" -m window --focus "$target"
