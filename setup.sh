#!/bin/sh

set -e

if [[ $# != 1 ]]; then
    echo syntax: $0 progname
    exit 1
fi

progname=$1
sed "s/^PROGNAME=.*/PROGNAME=$progname/" Makefile > Makefile.tmp
mv Makefile.tmp Makefile

for f in $(find -type l -maxdepth 1); do
    rm -f $f
done

ln -s wrapper.py $progname
for pymodule in pylib/cmd_*.py; do
	command=$(echo $pymodule | sed -n 's/^.*\/cmd_\(.*\).py$/\1/p' | sed 's/_/-/g')
	    ln -s $progname ${progname}-${command}
done
