#!/bin/bash

set -e
set +v

if [ -d .git ]; then
    git=true
else
    git=false
fi

progname=$(awk '/^Source/ {print $2}' debian/control)

for oldlink in $(find -maxdepth 1 -type l); do
    if [ "$git" == "true" ]; then
	git-rm $oldlink >& /dev/null || true
    fi
    rm -f $oldlink
done

ln -s wrapper.py $progname
if [ "$git" == "true" ]; then
    git-add $progname
fi

cmd_modules=(pylib/cmd_*.py)
if [ ${#cmd_modules[*]} -gt 1 ]; then
    for cmd_module in ${cmd_modules[*]}; do
	command=$(echo $cmd_module | sed -n 's/^.*\/cmd_\(.*\).py$/\1/p' | sed 's/_/-/g')
	newlink=${progname}-${command}
	
	ln -s $progname $newlink
	if [ "$git" == "true" ]; then
	    git-add $newlink
	fi
    done
fi


