#!/bin/bash

set -e

if [[ $# != 2 ]]; then
    echo syntax: $0 oldname newname
    exit 1
fi

oldname=$1
newname=$2
sed -i -e "s/^Source:.*/Source: $newname/; \
           s/^Package:.*/Package: $newname/; \
           s/^Maintainer:.*/Maintainer: $GIT_AUTHOR_NAME <$GIT_AUTHOR_EMAIL>/" debian/control

[ -f ${oldname}.leo ] && mv ${oldname}.leo ${newname}.leo
$(dirname $0)/updatelinks.sh
