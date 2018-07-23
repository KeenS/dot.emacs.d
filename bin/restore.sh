#!/bin/sh
rootdir=$( (cd $(dirname $0); cd ../; pwd) )
emacs -Q -batch --eval '(package-initialize)' --eval "(load \"$rootdir/bin/restore.el\")"
