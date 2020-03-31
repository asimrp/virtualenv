#!/bin/bash

export PATH=/build/bin:$PATH
#export LD_LIBRARY_PATH=~/gpdb/orca-install/lib

if [ "$1" = "-rr" ]; then RRMASTER="rr record"; fi
if [ "$1" = "-rr0" ]; then RR0="rr record"; fi
if [ "$1" = "-rr1" ]; then RR1="rr record"; fi
if [ "$1" = "-rr2" ]; then RR2="rr record"; fi
ulimit -c unlimited

$RR0 /bin/postmaster -D data-seg0 &
$RR1 /bin/postmaster -D data-seg1 &
$RR2 /bin/postmaster -D data-seg2 &

$RRMASTER /build/bin/postmaster -D data-master -E
