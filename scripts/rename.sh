#!/bin/sh

set -e

if [[ $# != 1 ]]; then
    echo syntax: $0 newname
    exit 1
fi

progname=$1
sed "s/^progname=.*/progname=$progname/" Makefile > Makefile.tmp
mv Makefile.tmp Makefile

$(dirname $0)/updatelinks.sh
