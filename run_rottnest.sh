#!/bin/bash

# Create personalised pandora_pg.json
echo "{ \"database\":\"postgres\", \"user\":\"$USER\", \"host\":\"localhost\", \"port\":\"5432\", \"password\":\"1234\" }" > ./pandora_pg.json

if [[ ! -d "rottnest" ]]; then
  echo "rottnest does not appear to be installed - have you run make?"
  exit 1
fi

BROWSER="$(xdg-mime query default text/html)"
BROWSER="${BROWSER/.desktop/}"

echo -n "Starting rottnest"

# Cursed trap kill-all on a subshell ensures ctrl-c kills everything...
(trap 'kill 0' SIGINT; export TOP_DIR="$PWD"; \
cd ./rottnest/applications/pandora || (kill 0 && exit 2); \
./run_apptainer.sh >/dev/null 2>/dev/null & \
# Sleeps are to provide startup time
cd "$TOP_DIR" || (kill 0 && exit 2); echo -n '.'; sleep 5; echo -n '.'; \
python ./rottnest/applications/rottnest_py/src/rottnest/server/server.py >/dev/null 2>/dev/null & \
cd "$TOP_DIR" || (kill 0 && exit 2); echo -n '.'; sleep 2; echo -n '.'; \
cd ./rottnest/applications/rottnest_js || (kill 0 && exit 2); \
npx vite --port 5175 >/dev/null 2>/dev/null & \
"$BROWSER" http://localhost:5175; kill 0)

