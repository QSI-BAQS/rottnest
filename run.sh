#!/bin/bash

CURRDIR=$(pwd)

echo "Running Pandora via Apptainer"
cd ./build/pandora
bash run_apptainer.sh main.py default_config fh 10 &
cd $CURRDIR

cd ./build/rottnest_py
echo "Running RottnestPy"
python src/rottnest/server/server.py &
cd $CURRDIR

cd ./build/rottnest
echo "Running Rottnest"
npm run dev




