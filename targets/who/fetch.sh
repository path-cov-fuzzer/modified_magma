#!/bin/bash
set -e

rm -rf $TARGET/repo
cp -r $TARGET/who/ $TARGET/repo

pushd $TARGET/repo
bash validate.sh
bash modify_Makefile.sh
popd

