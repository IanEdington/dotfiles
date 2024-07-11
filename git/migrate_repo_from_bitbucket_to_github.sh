#!/usr/bin/env bash
# Bash Strict Mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

HELP="
Usage: migrate_bitbucket_to_github <bitbucket_org> <github_org> [OPTIONS]

This script migrates a Bitbucket repository to GitHub. It requires an SSH
connection to Bitbucket and an authenticated \`gh\` instance.

Arguments:
    bitbucket_org         Bitbucket organization name
    github_org            GitHub organization name

Options:
    --repo=<repo_name>    Bitbucket repositories to migrate
    --gh-flags            Additional flags to pass to gh
    --dry-run             Print actions without executing them
    --help                Show this help message and exit

Example usage:
    migrate_bitbucket_to_github my_bitbucket_org my_github_org --repo=repo1
    migrate_bitbucket_to_github my_bb_org my_gh_org --repo=repo1 --repo=repo2

TODO: this only pushes the main branch, however we want to migrate EVERYTHING
"

WORKING_DIR=$(pwd)

# Get the repos and flags

repos=()
dry_run=false
for arg in "$@"; do
    if [[ $arg == --help ]]; then
        echo $HELP
    elif [[ $arg == --repo=* ]]; then
        repo="${arg#*=}"
        repos+=("$repo")
    elif [[ $arg == --gh-flags=* ]]; then
        additional_gh_flags="${arg#*=}"
    elif [[ $arg == --dry-run ]]; then
        dry_run=true
    fi
done

# Check if repos array is empty
if [[ ${#repos[@]} -eq 0 ]]; then
    echo "No repositories specified. Please provide at least one repository to migrate."
    exit 1
fi

# -------------
# Check that the repo names are valid
# -------------


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

tempdir=
# Create a temporary directory
tempdir=$(mktemp -d)

# For each repo pull the bitbucket repo, then create and push the github repo

for REPO_NAME in "${repos[@]}"; do
    echo "migrate bitbucket:$BITBUCKET_ORG/$REPO_NAME to github:$GITHUB_ORG/$REPO_NAME"

    if [[ $dry_run == true ]]; then
        continue
    fi

    # Actually do the migration

    # clone the repo from bitbucket setting the remote name as bitbucket
    git -c $tmpdir --quite clone --mirror --origin bitbucket git@bitbucket.org:$BITBUCKET_ORG/$REPO_NAME.git
    # create a repo on GitHub and push the code
    gh repo create $GITHUB_ORG/$REPO_NAME --private --push --source $tempdir/$REPO_NAME
    git -c $tmpdir/$REPO_NAME --quiet push origin --mirror
done;
