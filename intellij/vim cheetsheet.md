# Vim Cheat Sheet
Global
K - open man page for word under the cursor
gd - get declaration

## Cursor movement
H - move to top of screen
M - move to middle of screen
L - move to bottom of screen
5G - go to line 5
fx - jump to next occurrence of character x
tx - jump to before next occurrence of character x
} - jump to next paragraph (or function/block, when editing code)
{ - jump to previous paragraph (or function/block, when editing code)
zz - center cursor on screen
Ctrl + b - move back one full screen
Ctrl + f - move forward one full screen
Ctrl + d - move forward 1/2 a screen
Ctrl + u - move back 1/2 a screen

## Editing
J - join line below to the current one
cc - change (replace) entire line
cw - change (replace) to the end of the word
c$ - change (replace) to the end of the line

## Marking text (visual mode)
o - move to other end of marked area
Ctrl + v - start visual block mode
O - move to other corner of block
aw - mark a word
ab - a block with ()
aB - a block with {}
ib - inner block with ()
iB - inner block with {}

## Registers
:reg - show registers content "xy - yank into register x
"xp - paste contents of register x

## Marks
:marks - list of marks
ma - set current position for mark A `a - jump to position of mark A
y`a - yank text to position of mark A

## Macros
qa - record macro a
q - stop recording macro @a - run macro a
@@ - rerun last run macro

## Search and replace
:vimgrep /pattern/ {file} - search for pattern in multiple files.
:cn - jump to the next match :cp - jump to the previous match
:copen - open a window containing the list of matches

## Working with multiple files
Ctrl + ws - split window
Ctrl + ww - switch windows
Ctrl + wq - quit a window
Ctrl + wv - split window vertically

# Tabs
2gt - move to tab number #

