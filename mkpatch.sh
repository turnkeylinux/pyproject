#!/bin/sh

if [[ $# == 0 ]]; then
    echo Syntax: $0 progname
    exit -1
fi

PROGNAME=$1

PY_SORT_CMD="import fileinput, re;lines =[ line for line in fileinput.input() ]; lines.sort(key=lambda s: map(int, re.match(r'\s*v(\d+)\.(\d+)', s).groups()));print ''.join(lines),"

VERSION_LAST=`cg tag-ls | awk '{print $1}' | grep '^v' | python -c "$PY_SORT_CMD" | sed -n '$p'`
VERSION_NEXT=`echo $VERSION_LAST | \
    perl -n -e '/^v(\d+)\.(\d+)/ && printf "v%d.%d", $1, ($2+1)'`

echo "incrementing version to $VERSION_NEXT"

echo updating version.py
echo $VERSION_NEXT | \
    perl -n -e '/^v(\d+)\.(\d+)/ && printf "major=%d\nminor=%d\n", $1, $2' > version.py

echo cg commit -m \"version update $VERSION_LAST to $VERSION_NEXT\"
cg commit -m "version update $VERSION_LAST to $VERSION_NEXT"

PATCH_DIR=patches
if ! [ -d $PATCH_DIR ]; then
    mkdir -p $PATCH_DIR
fi

PATCH=$PROGNAME-${VERSION_NEXT}.diffs
echo writing delta patch series ${VERSION_LAST}..${VERSION_NEXT} to ${PATCH_DIR}/$PATCH

cg mkpatch -r ${VERSION_LAST}.. -d ${PATCH_DIR}/$PATCH

echo packaging delta patch series into ${PATCH_DIR}/${PATCH}.tar.bz2
tar -C ${PATCH_DIR} -jcvf ${PATCH_DIR}/${PATCH}.tar.bz2 $PATCH > /dev/null

cg tag $VERSION_NEXT HEAD
