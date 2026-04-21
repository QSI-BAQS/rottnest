#!/bin/bash

if [[ ! -d "rottnest" ]]; then
    echo "rottnest does not appear to be installed - have you run make?"
    exit 1
fi

BROWSER="$(xdg-mime query default text/html 2>/dev/null)"

if [[ "$BROWSER" == "" ]]; then
    # Mac - check and run Applications via `open`
    if [[ "$(uname -s)" == "Darwin" ]]; then
        if open -Ra "firefox" &>/dev/null; then
            BROWSER=(open -a firefox)
        elif open -Ra "Google Chrome" &>/dev/null; then
            BROWSER=(open -a "Google Chrome")
        elif open -Ra "Safari" &>/dev/null; then
            BROWSER=(open -a Safari)
        fi
    # Non-Mac Unix - hopefully $PATH is configured correctly
    else
        if which firefox &>/dev/null; then
            BROWSER=(firefox)
        elif which chrome &>/dev/null; then
            BROWSER=(chrome)
        elif which chromium &>/dev/null; then
            BROWSER=(chromium)
        fi
    fi
else
    BROWSER=("${BROWSER/.desktop/}")
fi

if [[ -z "${BROWSER[*]}" ]]; then
    echo "Could not find a supported browser, please install Firefox or Google Chrome and ensure they can be run (either from PATH or, on Mac, with \`open\`)"
fi

# Cursed trap kill-all on a subshell ensures ctrl-c kills everything...
(trap 'kill 0' SIGINT; \
TOP_DIR="$(pwd)"; \
python ./rottnest/applications/rottnest_py/src/rottnest/server/server.py & \
sleep 5; \
cd ./rottnest/applications/rottnest_js || (kill 0 && exit 2); \
npx vite --port 5175 &>/dev/null & \
cd "$TOP_DIR" || (kill 0 && exit 2); sleep 2; \
"${BROWSER[@]}" http://localhost:5175; wait; kill 0)
# ^ Unfortunately, we can't assume that $BROWSER will block, and so can't just exit when $BROWSER does
# (eg. firefox only blocks if there isn't already an open instance)
