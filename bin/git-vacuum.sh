#!/usr/bin/env bash

set -eu

GUARDED_BRANCHES="^(master|main|staging|release)$"
cmd=""
original_ref=""

usage() {
    cat <<EOM
Usage: $(basename "$0") [OPTION]
  -h        Display help

      This script will automatically delete branches that have already been
  merged into master (or main), staging, release. And then, it performs
  fast-forward merging.
EOM
}

# Simple argument parsing that works on both GNU and BSD systems.
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
done

# Detect GNU xargs. Prefer gxargs when available; otherwise verify that the
# system xargs supports --no-run-if-empty.
if command -v gxargs >/dev/null 2>&1; then
    cmd="gxargs"
elif printf '' | xargs --no-run-if-empty echo >/dev/null 2>&1; then
    cmd="xargs"
else
    echo "Error: GNU xargs is required to run" >&2
    exit 3
fi

# Verify we are inside a git repository.
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: Not a git repository" >&2
    exit 1
fi

# Refuse to run when the working tree is dirty so that branch checkouts do not
# fail or overwrite local changes.
if [ -n "$(git status --porcelain)" ]; then
    echo "Error: Working tree is dirty. Commit or stash changes before running." >&2
    exit 1
fi

# Remember the original branch (or commit when in detached HEAD).
original_ref=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse HEAD)

cleanup() {
    git checkout "$original_ref" >/dev/null 2>&1 || true
}
trap cleanup EXIT

git fetch --all -p

for root in release staging master main; do
    if ! git show-ref --verify --quiet "refs/heads/$root"; then
        continue
    fi

    echo "Cleaning the $root branch..."
    git checkout "$root" >/dev/null 2>&1

    if git merge --ff-only "origin/$root"; then
        git for-each-ref --format='%(refname:short)' --merged="$root" refs/heads/ \
            | grep -Ev "${GUARDED_BRANCHES}" \
            | grep -Fxv "$original_ref" \
            | ${cmd} --no-run-if-empty -d '\n' git branch -d
    else
        echo "Warning: Fast-forward merge failed for $root" >&2
    fi
done
