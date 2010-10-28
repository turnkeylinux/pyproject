#!/bin/sh
set -e
if [[ $# != 1 ]]; then
    echo syntax: $0 project-name
    exit 1
fi
name=$1

rm -f docs/README
rm -rf tests
rm -rf .git/
rm -f $0

git-init
git-add .

git-commit -m "Initialized project '$name' from pyproject template"


