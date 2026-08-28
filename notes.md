# things I want to do

- install: consolidate the scattered `echo_yellow "-[ ] ..."` checklist items
  (macOS/install, zsh/install, macOS/terminfo/install) into a single actionable
  checklist printed at the bottom of the run, instead of interleaved mid-output
- install: root `install` runs `python/install` twice (once "early" before
  Brewfile, again via the per-directory loop) and `packages/install` hits
  `externally-managed-environment` from pip; harmless today but worth a look
- quickadd to workflowy
- auto start `start-keybaord`
- i3wm: open notificaions when clicked
- fix start-keyboard script in wayland
- fix flameshot on wayland
- alfred look into https://github.com/albertlauncher/albert/issues/123

intellij:
- cmd+= - larger text
- cmd+- - smaller text

vscode:
- ;sr -> search all using vim
- <ctrl>n -> down in pane

vim:
- `md` files: stop tabing in when `-` exists on the previous line

# start using
magnifier '<Alt><Super>8'
magnifier-zoom-in '<Alt><Super>equal'
magnifier-zoom-out '<Alt><Super>minus'


# scoll speed
decrease scroll speed as per this articel: https://forums.linuxmint.com/viewtopic.php?t=375106

xinput --set-prop <ID> "libinput Scrolling Pixel Distance" 30
