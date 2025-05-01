#!/bin/bash


BUILDDIR=$1
source $BUILDDIR/venv/bin/activate
eval "$(pyenv init -)"
pyenv global 3.11

python --version

cd $BUILDDIR/pandora

cd apptainer

echo "Running docker pull postgres (make sure you have docker running in the background)"
sudo docker pull postgres

echo "Building base"
bash apptainer_util.sh base

echo "Building image"
bash apptainer_util.sh build

cd ..
echo "Building pandora"
pip install -e .

RESRET=$?
if test $RESRET -ne 0; then
  echo 'Building pandora failed, retrying'
  pip install -e .

  RESRET=$?
  if test $RESRET -ne 0; then
    echo 'Retry failed'
    exit 1
  fi
else
  exit 0
fi


