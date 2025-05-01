#!/bin/env

BUILDDIR=$1
cd $BUILDDIR/rottnest_node
npm i

RESRET=$?
if test $RESRET -ne 0; then
  echo 'Building rottnest failed'
  exit 1
else
  exit 0
fi
