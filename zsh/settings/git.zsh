# Don't try to glob with zsh so you can do stuff like ga *foo* and correctly have git add the right stuff
alias git='noglob git'
# alias stree='/Applications/SourceTree.app/Contents/Resources/stree'

# Makes git auto completion faster favouring for local completions
# __git_files () {
#     _wanted files expl 'local files' _files
# }

alias gi='$EDITOR .gitignore'
alias egs='$IDE `git status --short -- . | grep '"'"'^ \?[MAR?]'"'"' | awk '"'"'{print $NF}'"'"'`'
alias egh='$EDITOR `git diff --name-only HEAD^`'

# Git Add
#alias ga="git add"
function ga() {
    if [[ "${1}" == "" ]]; then
        git add -u
    else
        git add $@
    fi
}
alias gaa="ga -A"
alias gap="ga -p"
alias guns="git unstage"

# Git Commit
alias gc="git commit"
alias gcm="gc -m"
alias gct="gc -m temp --no-verify"
alias gcam="ga -A && gc -m"

# Git View
alias gs="git status"
alias gsh="git show"

alias gd="git diff"
alias gdc="gd --cached -w"
alias gds="gd --staged -w"

# git log
local GIT_LOG_FORMAT="format:%>|(18,trunc)%C(blue)%ad %C(yellow)%<(8)%h%C(green)%D %C(blue)%s %C(magenta)[%an]"
local GIT_LOG="log --decorate --graph --format=\"$GIT_LOG_FORMAT\""
alias gl="git --no-pager $GIT_LOG --color=always  | head"
alias gll="git $GIT_LOG --branches"
alias glla="git $GIT_LOG --all"
alias gllr="git $GIT_LOG"
alias gli="git log -1 HEAD"

# git search
alias gpickaxe="git log -p -S"

# Git Stash
alias gst="git stash"
alias gstl="gst list"
alias gstp="gst pop"
alias gsta="gst apply"

# Git Branch
alias gco="git checkout"
alias gcoom="gco origin/HEAD"
alias gcoog="gco origin/green"
alias gbn="gco -b" # new branch aka checkout -b
alias gb="git --no-pager branch -v --sort=-committerdate"
alias gpub="git recent-branches publish"
alias gtr="git recent-branches track"
alias gdmb="git branch --merged | grep -v "\*" | xargs -n 1 git branch -d"
alias gbdg="gf && gcoom && git branch -vv | grep ': gone]' | grep -v '^*' | awk '{ print \$1 }' | xargs -n 1 git branch -D"
alias gbd="git branch -D -v"
alias gbdr="git push origin --delete"

# Merging
alias gm="git merge"
alias gmff="gm --ff-only"
alias gmn="gm --no-ff"
alias gms="gm --squash"

# Git Changing history
alias gcp="git cherry-pick -x"
alias gunc="git uncommit"
alias gca="gc --amend"
alias gcae="gc --amend --no-edit"
alias gcaa="gc --amend --reset-author"
alias grs="git reset"
alias grsh="grs --hard"
alias gr="git rebase"
alias grom="git rebase origin/HEAD"
alias grog="git rebase origin/green"
alias gra="gr --abort"
alias ggrc="gr --continue"
alias gbi="gr --interactive"

# Git Remote
alias grv="git remote -v"
alias grr="git remote rm"
alias grad="git remote add"
alias gf="git fetch --prune"

# Staged and cached are the same thing
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gpa="git push --all"
alias gpu='git push -u origin `git rev-parse --abbrev-ref HEAD`'
alias gpl="git pull"
alias gplr="git pull --rebase"

alias gcln="git clean"
alias gclndf="gcln -df"
alias gclndfx="gcln -dfx"

alias gsm="git submodule"
alias gsmi="gsm init"
alias gsmu="gsm update"
alias gbg="git bisect good"
alias gbb="git bisect bad"
alias gt="git tag"
