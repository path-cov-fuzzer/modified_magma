#!/bin/bash
set -e

rm -rf $TARGET/repo
cp -r $TARGET/LAVA-M/ $TARGET/repo

for program in base64 md5sum uniq who; do

	pushd $TARGET/repo/$program/
	bash validate.sh
	bash modify_Makefile.sh
	popd
	
done

