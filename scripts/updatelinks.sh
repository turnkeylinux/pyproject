#!/bin/sh

set -e
set +v

if [ -d .git ]; then
    git=true
else
    git=false
fi

progname=$(sed -n 's/^progname=//p' Makefile)

for oldlink in $(find -type l -maxdepth 1); do
    if [ "$git" == "true" ]; then
	git-rm $oldlink >& /dev/null || true
    fi
    rm -f $oldlink
done

ln -s wrapper.py $progname
git-add $progname

for pymodule in pylib/cmd_*.py; do
	command=$(echo $pymodule | sed -n 's/^.*\/cmd_\(.*\).py$/\1/p' | sed 's/_/-/g')
	newlink=${progname}-${command}
	
	ln -s $progname $newlink
	if [ "$git" == "true" ]; then
	    git-add $newlink
	fi
done

