#!/bin/sh

SMLSHARP=/usr/local/bin/smlsharp
OPTIONS=-ftypecheck-only


${SMLSHARP} ${OPTIONS} "$@" 2>&1 | ruby -ne 'BEGIN {buf=""}; if $_ =~ /^\s/ then buf += $_.chomp + "\\n" else puts buf; buf = $_.chomp end; END{puts buf}'
