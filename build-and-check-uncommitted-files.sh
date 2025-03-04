#!/usr/bin/env bash
set -e # Exit if one of commands exit with non-zero exit code
set -u # Treat unset variables and parameters other than the special parameters ‘@’ or ‘*’ as an error
set -o pipefail # Any command failed in the pipe fails the whole pipe
# set -x # Print shell commands as they are executed (or you can try -v which is less verbose)

cd "$(dirname "$0")"
./build-debug.sh
if [ ! -z "$(git status --porcelain)" ]; then
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    echo !!! Uncommitted files detected !!!
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    git status
    exit 1
fi
