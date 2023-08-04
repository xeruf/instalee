#!/bin/sh -x
# Sets up this repo to be used on a portable stick, 
# assuming it is in a directory "instalee" below the root of the medium
git remote set-url origin https://github.com/xeruf/instalee
git remote set-url --push origin github.com:xeruf/instalee.git
git config core.eol lf
git config core.fileMode false # FAT has no proper permissions
cp -v i.cmd ../../
