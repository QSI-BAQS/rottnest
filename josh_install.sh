#!/bin/bash

# COLORS
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' 

# Save base dir
BASE_DIR=$(pwd)
BUILDDIR="$BASE_DIR/build"
LOG_FILE="$BASE_DIR/install.log"

# Make build dir and logs dir
mkdir -p "$BUILDDIR" 2> /dev/null
mkdir -p "$BASE_DIR/logs" 2> /dev/null

# Init log file
echo "$(date): Installation started" > "$LOG_FILE"

# Helper to log messages
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

# Helper to check deps
check_deps() 
{
	log_message "INFO" "Checking for required dependencies..."

	if [ ! -f "dep_list.txt" ]; then
        	log_message "ERROR" "Missing dep_list.txt file"
        	return 1
    	fi

    	RETRES=0
    	while IFS= read -r line; do
        	[[ -z "$line" || "$line" =~ ^# ]] && continue
        
		local DEPCMD=$line
        	command -v "$DEPCMD" > /dev/null 2>&1
        	DEPRES=$?
        
        	if test $DEPRES -ne 0; then
            		log_message "ERROR" "Missing $DEPCMD, required for installation"
            		RETRES=1
        	else
            		log_message "SUCCESS" "$DEPCMD found"
        	fi
    	done < dep_list.txt
    
    	return $RETRES 
}

# Process dep commands
process_dep_cmd() 
{
   	local INCMD=$1
    	local URLARG=$2
    	local EXTARG=$3
    	local SCRIPT=$4

    	log_message "INFO" "Processing dependency: $EXTARG"

    	case $INCMD in
        	git )
            		log_message "INFO" "Cloning repository: $URLARG"
            		git clone "$URLARG" "$BUILDDIR/$EXTARG" >> "$LOG_FILE" 2>&1
            		
			if [ $? -ne 0 ]; then
                		log_message "ERROR" "Failed to clone repository: $URLARG"
                	
				return 1
            		fi

            		if [ -f "scripts/$SCRIPT" ]; then
                		log_message "INFO" "Running post-clone script: scripts/$SCRIPT"
                		bash "scripts/$SCRIPT" "$BUILDDIR" >> "$LOG_FILE" 2>&1
                		if [ $? -ne 0 ]; then
                    			log_message "ERROR" "Script failed: scripts/$SCRIPT"
                    			return 1
                		fi
            		else
                		log_message "WARNING" "Post-clone script not found: scripts/$SCRIPT"
            		fi
            	;;

        	curl )
            		log_message "INFO" "Downloading: $URLARG"
            		curl -L "$URLARG" > "$EXTARG" 2>> "$LOG_FILE"
            		if [ $? -ne 0 ]; then
                		log_message "ERROR" "Failed to download: $URLARG"
                		return 1
            		fi

            		if [ -f "scripts/$SCRIPT" ]; then
                		log_message "INFO" "Running post-download script: scripts/$SCRIPT"
                		bash "scripts/$SCRIPT" "$BUILDDIR" >> "$LOG_FILE" 2>&1
                		if [ $? -ne 0 ]; then
                    			log_message "ERROR" "Script failed: scripts/$SCRIPT"
                    			return 1
                		fi
            		else
                		log_message "WARNING" "Post-download script not found: scripts/$SCRIPT"
            		fi
            	;;

        	*)
            		log_message "ERROR" "Unknown command: $INCMD"
            		return 1
            	;;
    	esac

    	return 0
}

# Function to set up Python environment
setup_python_env() 
{
	log_message "INFO" "Setting up Python environment"

	log_message "INFO" "Creating virtual environment in $BUILDDIR/venv"
    	virtualenv "$BUILDDIR/venv" >> "$LOG_FILE" 2>&1
    	if [ $? -ne 0 ]; then
        	log_message "ERROR" "Failed to create virtual environment"
        	return 1
    	fi

    	log_message "INFO" "Activating virtual environment"
    	source "$BUILDDIR/venv/bin/activate"
    	if [ $? -ne 0 ]; then
        	log_message "ERROR" "Failed to activate virtual environment"
        	return 1
    	fi

    	# Added this check as install was freezing at a y/n prompt.
	if pyenv versions --bare 2>&1 | grep "3.11"; then
		log_message "INFO" "Python 3.11 already installed."
	else
		log_message "INFO" "Installing Python 3.11"

		pyenv install 3.11 >> "$LOG_FILE" 2>&1
    		if [ $? -ne 0 ]; then
        		log_message "ERROR" "Failed to install Python 3.11"
        		return 1
    		fi
	fi

    	eval "$(pyenv init -)"
    	pyenv global 3.11
    	log_message "SUCCESS" "Python environment setup complete"

    	return 0
}

# Helper to process all dependencies
process_deps() 
{
   	if [ ! -f "install_list.csv" ]; then
        	log_message "ERROR" "Missing install_list.csv file"
        	return 1
    	fi

    	log_message "INFO" "Processing dependencies from install_list.csv"

    	local dep_count=0
    	local success_count=0

    	while IFS= read -r line; do
        	[[ -z "$line" || "$line" =~ ^# ]] && continue

        	dep_count=$((dep_count + 1))

        	DEPNAME=$(echo "$line" | cut -d',' -f1)
        	CMDKIND=$(echo "$line" | cut -d',' -f2)
        	REPOURL=$(echo "$line" | cut -d',' -f3)
        	ESCRIPT=$(echo "$line" | cut -d',' -f4)
        	EXTRARG=$(echo "$line" | cut -d',' -f5)

        	log_message "INFO" "Processing dependency $dep_count: $DEPNAME"

        	process_dep_cmd "$CMDKIND" "$REPOURL" "$EXTRARG" "$ESCRIPT"
        	PROCRES=$?

        	if [ $PROCRES -ne 0 ]; then
            		log_message "ERROR" "Failed to process dependency: $DEPNAME"
            		return 1
        	else
            		success_count=$((success_count + 1))
            		log_message "SUCCESS" "Successfully installed: $DEPNAME"
        	fi

    	done < install_list.csv

    	log_message "SUCCESS" "Processed $success_count/$dep_count dependencies successfully"
    	
	return 0
}

# Capture for clean exit.
trap 'echo -e "\n${RED}Installation interrupted. Check $LOG_FILE for details.${NC}"; exit 1' SIGINT SIGTERM

# Main method
main() 
{
    	echo -e "\n${BLUE}┌──────────────────────────────────────┐${NC}"
    	echo -e "${BLUE}│          ROTTNEST INSTALLER          │${NC}"
    	echo -e "${BLUE}└──────────────────────────────────────┘${NC}\n"

    	log_message "INFO" "Starting installation process for rottnest"
    	log_message "INFO" "Build directory: $BUILDDIR"
    	log_message "INFO" "Log file: $LOG_FILE"
	log_message "INFO" "Please run 'tail -f install.log' to see progress"

    	# Step 1: Check dependencies
    	echo -e "\n${BLUE}Step 1: Checking dependencies${NC}"
    	check_deps
    	CAN_INSTALL=$?

    	if [ $CAN_INSTALL -ne 0 ]; then
        	log_message "ERROR" "Unable to install rottnest, missing commands/dependencies required"
        	echo -e "\n${RED}Installation failed. Check $LOG_FILE for details.${NC}\n"
        	exit 1
    	fi
    	
	log_message "SUCCESS" "All dependencies found"

    	# Step 2: Setup Python environment
    	echo -e "\n${BLUE}Step 2: Setting up Python environment${NC}"
    	setup_python_env
    	if [ $? -ne 0 ]; then
        	log_message "ERROR" "Failed to set up Python environment"
        	echo -e "\n${RED}Installation failed. Check $LOG_FILE for details.${NC}\n"
        	exit 1
    	fi

    	# Step 3: Process dependencies
    	echo -e "\n${BLUE}Step 3: Installing project dependencies${NC}"
    	process_deps
    	if [ $? -ne 0 ]; then
        	log_message "ERROR" "Failed to process dependencies"
        	echo -e "\n${RED}Installation failed. Check $LOG_FILE for details.${NC}\n"
        	exit 1
    	fi

    	# Installation complete
    	echo -e "\n${BLUE}┌──────────────────────────────────────┐${NC}"
    	echo -e "${BLUE}│  INSTALLATION COMPLETED SUCCESSFULLY │${NC}"
    	echo -e "${BLUE}└──────────────────────────────────────┘${NC}\n"

    	log_message "INFO" "Installation completed successfully"

    	echo -e "${GREEN}Rottnest has been installed successfully!${NC}"
    	echo -e "${YELLOW}To start the development environment, run:${NC}"
    	echo -e "  ./run.sh\n"

    	return 0
}

# Main call
main
