#!/bin/bash

# COLORS
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

BASE_DIR=$(pwd)
LOG_FILE="$BASE_DIR/install.log"

log_message()
{
	local level=$1
	local message=$2
	echo "$(date): [$level] $message" >> "$LOG_FILE"

	case $level in
		"INFO")
			echo -e "${BLUE}[INFO]${NC} $message"
			;;
		"SUCCESS")
			echo -e "${GREEN}[SUCCESS]${NC} $message"
			;;
		"WARNING")
			echo -e "${YELLOW}[WARNING]${NC} $message"
			;;
		"ERROR")
			echo -e "${RED}[ERROR]${NC} $message"
			;;
		*)
			echo -e "$message"
			;;
	esac
}

log_message "INFO" "Clearing build directory"

if [ -d "build" ]; then
	rm -rf build
	if [ -d "build" ]; then
		log_message "ERROR" "Build dir not deleted, please check manually"
		exit 1
	else
		log_message "SUCCESS" "Build directory deleted"
	fi
else
	log_message "WARNING" "Build directory did not exist"
fi

exit 0
