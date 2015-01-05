#!/bin/sh
rootdir=$( (cd $(dirname $0); cd ../; pwd) )
emacs -Q -batch --eval '(package-initialize)' --eval '(pp package-alist)' > "${rootdir}"/backup/packages.el
