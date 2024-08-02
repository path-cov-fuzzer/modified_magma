#!/bin/bash
set -e

rm -rf $TARGET/repo
cp -r $TARGET/md5sum/ $TARGET/repo

pushd $TARGET/repo
bash validate.sh
bash modify_Makefile.sh
popd
	
