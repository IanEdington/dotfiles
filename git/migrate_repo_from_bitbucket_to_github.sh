#!/usr/bin/env bash
# Bash Strict Mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
#set -euo pipefail
#IFS=$'\n\t'

HELP=$(cat << EndOfMessage
This script migrates a Bitbucket repository to GitHub.

Usage: migrate_bitbucket_to_github <bitbucket_org> <github_org> [OPTIONS]

Requires an SSH for Bitbucket and an authenticated \`gh\` instance

Arguments:
    bitbucket_org         Bitbucket organization name
    github_org            GitHub organization name

Options:
    --repo=<repo_name>    Bitbucket repositories to migrate (required)
    --dir                 parent directory to put all repos
    --dry-run             Print actions without executing them
    --help                Show this help message and exit

Example usage:
    migrate_bitbucket_to_github my_bitbucket_org my_github_org --repo=repo1
    migrate_bitbucket_to_github my_bb_org my_gh_org --repo=repo1 --repo=repo2

TODO: this only pushes the main branch, however we want to migrate EVERYTHING
EndOfMessage
)

WORKING_DIR=$(pwd)

# Get the repos and flags

repos=()
dry_run=false
for arg in "$@"; do
    if [[ $arg == --help ]]; then
        echo "$HELP"
        exit
    elif [[ $arg == --repo=* ]]; then
        repo="${arg#*=}"
        repos+=("$repo")
    elif [[ $arg == --dir ]]; then
        dir_arg="${arg#*=}"
    elif [[ $arg == --dry-run ]]; then
        dry_run=true
    fi
done

# -------------
# Check that args and flags are valid
# -------------

# Check if repos array is empty
if [[ ${#repos[@]} -eq 0 ]]; then
    echo "No repositories specified. Please provide at least one repository to migrate."
    exit 1
fi

# checks that the first argument is alphanumberic plus `-_`
# this might be too simplistic
if [[ $1 =~ ^[a-zA-Z0-9_-]+$ ]]; then
    BITBUCKET_ORG=$1
else
    echo "this might be an invalid Bitbucket organization name: $1"
    exit 1
fi

if [[ $2 =~ ^[a-zA-Z0-9_-]+$ ]]; then
    GITHUB_ORG=$2
else
    echo "this might be an invalid GitHub organization name: $2"
    exit 1
fi

# -----------
# Do the work
# -----------

# Create a temporary directory
temp_dir="${dir_arg:-$(mktemp -d)}"

# For each repo pull the bitbucket repo, then create and push the github repo
for REPO_NAME in "${repos[@]}"; do
    echo "migrate bitbucket:$BITBUCKET_ORG/$REPO_NAME to github:$GITHUB_ORG/$REPO_NAME"

    if [[ $dry_run == true ]]; then
        continue
    fi

    # Actually do the migration

    temp_repo="$temp_dir/$REPO_NAME.git" 

    # clone the repo from bitbucket setting the remote name as bitbucket
    git -C $temp_dir clone --mirror --origin bitbucket git@bitbucket.org:$BITBUCKET_ORG/$REPO_NAME.git --quiet
    git -C $temp_repo remote update

    # create a repo on GitHub the the repo already exists ignore the error
    set +e
    gh repo create "$GITHUB_ORG/$REPO_NAME" --private > /dev/null 2&>1
    set -e

    # add the github origin
    git -C $temp_repo remote add origin "git@github.com:$GITHUB_ORG/$REPO_NAME.git"
    # push all the ref
    git -C $temp_repo push origin --mirror --force --quiet

    echo "completed migration"
    echo ""
done;

echo "bitbucket to github migration completed without errors"
