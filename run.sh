#!/bin/bash

# COLORS 
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # [Base term color?]

# Store base dir
BASE_DIR=$(pwd)
PIDS=()
SERVICE_NAMES=()

# Boxes and colors please!
echo -e "\n${BLUE}┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}│        ROTTNEST DEV LAUNCHER         │${NC}"
echo -e "${BLUE}└──────────────────────────────────────┘${NC}\n"

launch_service() 
{
	local name=$1
	local dir=$2
	local cmd=$3
    
    	echo -e "${YELLOW}[STARTING]${NC} $name"
    
    	# Sdout to logs instead of main term.
    	mkdir -p ./logs
    	local log_file="./logs/${name}.log"

    	cd "$BASE_DIR/$dir" || 
	{
        	echo -e "${RED}[ERROR]${NC} Could not navigate to $dir"
        	return 1
    	}
    
    	# Run and capture PID
    	eval "$cmd" > "$BASE_DIR/$log_file" 2>&1 &
    	local pid=$!
    
    	cd "$BASE_DIR"
    	PIDS+=("$pid")
    	SERVICE_NAMES+=("$name")
    
    	echo -e "${GREEN}[LAUNCHED]${NC} $name (PID: $pid, Logs: $log_file)"
    	return 0
}

# All services in parallel
echo -e "${BLUE}Launching development services in parallel...${NC}\n"

# Pandora
launch_service "Pandora" "./build/pandora" "bash run_apptainer.sh main.py default_config fh 10"

# RottnestPy
launch_service "RottnestPy" "./build/rottnestpy" "python src/rottnest/server/server.py"

# Rottnest (keep in foreground for better Ctrl+C handling)
launch_service "Rottnest" "./build/rottnest" "npm run dev"

# Summary
echo -e "\n${BLUE}┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}│   SERVICES LAUNCHED SUCCESSFULLY     │${NC}"
echo -e "${BLUE}└──────────────────────────────────────┘${NC}"
echo -e "\n${YELLOW}Services running in background:${NC}"

for i in "${!SERVICE_NAMES[@]}"; do
	echo -e "  - ${GREEN}${SERVICE_NAMES[$i]}${NC} (PID: ${PIDS[$i]}, Log: ./logs/${SERVICE_NAMES[$i]}.log)"
done

echo -e "\n${YELLOW}To view logs:${NC}"
echo -e "  tail -f ./logs/SERVICE_NAME.log"

echo -e "\n${YELLOW}To access front end:${NC}"
echo -e "  http://localhost:5173/"

echo -e "\n${BLUE}Press Ctrl+C to terminate all services${NC}\n"

trap 'echo -e "\n${RED}Shutting down all services...${NC}"; kill ${PIDS[*]} 2>/dev/null; echo -e "${GREEN}All services terminated.${NC}"; exit 0' SIGINT SIGTERM

wait
