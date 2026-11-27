#!/bin/bash

if [[ ! -d "rottnest" ]]; then
    echo "rottnest does not appear to be installed - have you run make?"
    exit 1
fi

python ./rottnest/applications/rottnest_py/src/rottnest/server/server.py &
sleep 3;
cd ./rottnest/applications/rottnest_js
npx vite --port 5175 --host &>/dev/null
