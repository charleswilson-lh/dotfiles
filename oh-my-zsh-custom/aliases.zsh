# Personal Aliases for use in terminals

# Git helper functions
function git-prune-gone() {
  git fetch --prune origin && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d
}

function git-prune-gone-force() {
  git fetch --prune origin && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
}

# Git fetch all, prune deleted, update tags, with force, make local like remote
alias gfaf='git fetch --all --tags --prune --jobs=10 --force'

# Python alias
alias python=python3

# Add your custom aliases below
# Examples:
# alias ll='ls -la'
# alias ..='cd ..'
# alias ...='cd ../..'
