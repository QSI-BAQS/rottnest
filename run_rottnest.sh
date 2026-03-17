#!/bin/bash

if [[ ! -d "rottnest" ]]; then
    echo "rottnest does not appear to be installed - have you run make?"
    exit 1
fi

BROWSER="$(xdg-mime query default text/html)"

if [[ "$BROWSER" == "" ]]; then
    if [[ $(which firefox; echo "$?") -eq 0 ]]; then
        BROWSER=firefox
    elif [[ $(which chrome; echo "$?") -eq 0 ]]; then
        BROWSER=chrome
    elif [[ $(which chromium; echo "$?") -eq 0 ]]; then
        BROWSER=chromium
    else
        echo "Could not determine a web-browser to run the frontend with"
        exit 1
    fi
else
    BROWSER="${BROWSER/.desktop/}"
fi

echo -n "Starting rottnest."

# Cursed trap kill-all on a subshell ensures ctrl-c kills everything...
(trap 'kill 0' SIGINT; \
python ./rottnest/applications/rottnest_py/src/rottnest/server/server.py >/dev/null 2>/dev/null & \
echo -n '.'; sleep 2; echo -n '.'; \
cd ./rottnest/applications/rottnest_js || (kill 0 && exit 2); \
npx vite --port 5175 >/dev/null 2>/dev/null & \
echo -n '.'; sleep 3; echo '.'; echo -e "\nUse <ctrl>+c to end the rottnest server"; $BROWSER http://localhost:5175; wait; kill 0)
# ^ Unfortunately, we can't assume that $BROWSER will block, and so can't just exit when $BROWSER does
# (eg. firefox only blocks if there isn't already an open instance)
