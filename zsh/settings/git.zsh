# Don't try to glob with zsh so you can do stuff like ga *foo* and correctly have git add the right stuff
alias git='noglob git'
# alias stree='/Applications/SourceTree.app/Contents/Resources/stree'

# Makes git auto completion faster favouring for local completions
__git_files () {
    _wanted files expl 'local files' _files
}

alias gi='$EDITOR .gitignore'
# alias egs='$EDITOR `git ls-files -m`'
alias egs='$EDITOR `git status --short -- . | awk '"'"'{print $2}'"'"'`'
alias egh='$EDITOR `git diff --name-only HEAD^`'

# Git flow
alias gfi="git flow init"
alias gff="git flow feature"
alias gffs="gff start"
alias gfff="gff finish"
alias gffr="gff rebase"
alias gffp="gff publish"
alias gfr="git flow release"
alias gfv="git flow version"
alias gfx="git flow hotfix"
alias gfs="git flow support"

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
alias gc="git commit --no-verify"
alias gcm="gc -m"
alias gcam="ga -A && gc -m"

# Git View
alias gs="git status"
alias gsh="git show"
alias gl="gldog | head"
alias gll="gladog"
alias gladog="gldog --all"
alias gldog="git log --decorate --graph"
alias gli="git log -1 HEAD"
alias gd="git diff"
alias gdc="gd --cached -w"
alias gds="gd --staged -w"

# Git Stash
alias gst="git stash"
alias gstl="gst list"
alias gstp="gst pop"
alias gsta="gst apply"

# Git Branch
alias gco="git checkout"
alias gbn="gco -b" # new branch aka checkout -b
alias gb="git branch -v"
alias gpub="git recent-branches publish"
alias gtr="git recent-branches track"
alias gdmb="git branch --merged | grep -v "\*" | xargs -n 1 git branch -d"

# Git Delete local and remote branch
# http://stackoverflow.com/a/35324551/4301584
function gitdelete(){
    git push origin --delete $1
    git branch -D $1
}

# Merging
alias gm="git merge"
alias gmff="gm --ff-only"
alias gmn="gm --no-ff"
alias gms="gm --squash"

# Git Changing history
alias gcp="git cherry-pick -x"
alias gunc="git uncommit"
alias gca="gc --amend"
alias gcaa="gc --amend --reset-author"
alias grs="git reset"
alias grsh="grs --hard"
alias gr="git rebase"
alias gra="gr --abort"
alias ggrc="gr --continue"
alias gbi="gr --interactive"

# Git Remote
alias grv="git remote -v"
alias grr="git remote rm"
alias grad="git remote add"
alias gf="git fetch --all --prune"
alias gbd="git branch -D -v"

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
