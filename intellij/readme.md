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
    - [ ] custom fold text
- [ ] auto closing brackets
- [ ] ~solarized~: UI theme doesn't look good with Solarized editor theme
- [x] macros
- [x] font can be changed to the one I want.
- [ ] smart case regex
- [ ] vs and sp the other direction

- Toggle settings:
    - [ ] cot - synTax linting
    - [ ] cos - spelling
    - [ ] cok - colorscheme
    - [x] cow - line wrap
    - [x] coh - highlighting
    - [x] coi - case in
    - [x] con - linenumbers
    - [x] cor - relativenumber
- [x] line above or below - ]<space> (unimpaired)
- [ ] next search result ]q
- git hunk manipulation - not currently possible
    - [x] ]c - next chunk
    - [  ] ;hu - checkout head hunk
    - [  ] ;hs - stage hunk
- [x] next linting error ]l - ]p
- [ ] ;t to run current test
- [x] move lines up or down - ]e
- [ ] search replace current file - ;sr
- [x] fuzzyfind filename in project <ctrl-p> -> <s-m-o>
- [x] search text string an project - :ag
- [x] textareas `action` `ia` `wl{t])`
- [ ] comment uncomment text <ctrl-\>
- [ ] autoformat with =

- [x] vimsurround 
- [ ] show tabs and trailing whitespace characters

- ;v ;c ;x for copy paste
