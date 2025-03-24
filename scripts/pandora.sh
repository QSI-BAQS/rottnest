#!/bin/bash

BUILDDIR=$1
cd $BUILDDIR/pandora

cd util

echo "Running docker pull postgres (make sure you have docker running in the background)"
sudo docker pull postgres

echo "Building base"
bash apptainer_util.sh base

echo "Building image"
bash apptainer_util.sh build

echo "Building pandora"
RESRET=$(pip install -e .)

if test $RESRET -ne 0; then
  echo 'Building pandora failed'
  exit 1
else
  exit 0
fi


