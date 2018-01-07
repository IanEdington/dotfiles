# Thinking of moving from vim to Intellij IDEA

## Why?
### ease of setup
Every feature I add to vim is taking more and more time. Many of these features come baked into modern IDE's.

### reliability of tools set
I have been finding vim more and more frustrating to use as I started demanding more from my editor.
Tools that rely on knowledge of the code, like code completion or jump to definition, tend to be incomplete or have major bugs.

### difficulty of open source
I like open source and would be willing to pay for a better alternative, however, I'm not interested in paying for a substandard experience, and the high quality experiences are already free so I don't feel the need to pay for them.
This has lead me to evaluate intellij and Visual Studio

## Things to look into:

- [x] folding: works
- [ ] auto closing brackets
- [ ] ~solarized~: UI theme doesn't look good with Solarized editor theme
- [ ] macros

## Vim bindings:
- [ ] cot, cow, coh, coi
- [ ] line above or below - ]<space>
- [ ] move lines up or down - ]e
- [ ] search replace buffer - ;sr

## Vim support

### List of Supported Set Commands
https://github.com/JetBrains/ideavim/blob/master/doc/set-commands.md

The following `:set` commands can appear in `~/.ideavimrc` or set manually in the command mode:

    'clipboard'      'cb'    clipboard options
    'digraph'        'dg'    enable the entering of digraphs in Insert mode
    'gdefault'       'gd'    the ":substitute" flag 'g' is default on
    'history'        'hi'    number of command-lines that are remembered
    'hlsearch'       'hls'   highlight matches with last search pattern
    'ignorecase'     'ic'    ignore case in search patterns
    'iskeyword'      'isk'   defines keywords for commands like 'w', '*', etc.
    'incsearch'      'is'    show where search pattern typed so far matches
    'matchpairs'     'mps'   pairs of characters that "%" can match
    'nrformats'      'nf'    number formats recognized for CTRL-A command
    'number'         'nu'    print the line number in front of each line
    'relativenumber' 'rnu'   show the line number relative to the line with
                             the cursor
    'scroll'         'scr'   lines to scroll with CTRL-U and CTRL-D
    'scrolljump'     'sj'    minimum number of lines to scroll
    'scrolloff'      'so'    minimum nr. of lines above and below cursor
    'selection'      'sel'   what type of selection to use
    'showmode'       'smd'   message on status line to show current mode
    'sidescroll'     'ss'    minimum number of columns to scroll horizontal
    'sidescrolloff'  'siso'  min. nr. of columns to left and right of cursor
    'smartcase'      'scs'   no ignore case when pattern has uppercase
    'timeout'        'to'    use timeout for mapped key sequences
    'timeoutlen'     'tm'    time that is waited for a mapped key sequence
    'undolevels'     'ul'    maximum number of changes that can be undone
    'viminfo'        'vi'    information to remember after restart
    'visualbell'     'vb'    use visual bell instead of beeping
    'wrapscan'       'ws'    searches wrap around the end of the file
