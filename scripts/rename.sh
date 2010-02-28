#!/bin/sh

set -e

if [[ $# != 1 ]]; then
    echo syntax: $0 newname
    exit 1
fi

progname=$1
cat Makefile | \
awk 'BEGIN {p = 1} /^init:/ { p=0 } /^updatelinks:/ { p=1} p { print }' | \
sed "s/make init/make rename/; \
     s/^progname=.*/progname=$progname/" > Makefile.tmp
mv Makefile.tmp Makefile

$(dirname $0)/updatelinks.sh
