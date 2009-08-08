#!/bin/sh

if [[ $# == 0 ]]; then
    echo Syntax: $0 progname
    exit -1
fi

PROGNAME=$1

VERSION_LAST=`cg tag-ls | awk '{print $1}' | grep '^v' | sort | sed -n '$p'`
VERSION_NEXT=`echo $VERSION_LAST | \
    perl -n -e '/^v(\d+)\.(\d+)/ && printf "v%d.%d", $1, ($2+1)'`

echo updating version.py
echo $VERSION_NEXT | \
    perl -n -e '/^v(\d+)\.(\d+)/ && printf "major=%d\nminor=%d\n", $1, $2' > version.py

echo commiting new version
cg commit -m "version update $VERSION_LAST -> $VERSION_NEXT"

echo "incrementing version to $VERSION_NEXT"

PATCH_DIR=patches
if ! [ -d $PATCH_DIR ]; then
    mkdir -p $PATCH_DIR
fi

PATCH_FILE=${PATCH_DIR}/$PROGNAME-${VERSION_NEXT}.diff
echo writing delta patch ${VERSION_LAST}..${VERSION_NEXT} to $PATCH_FILE

cg mkpatch -r ${VERSION_LAST}.. > $PATCH_FILE

cg tag $VERSION_NEXT HEAD


