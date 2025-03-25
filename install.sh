#!/bin/bash

#
# Install script for rottnest and its dependencies
# It will retrieve all the repos and build them
#

mkdir -p ./build 2> /dev/null
BUILDDIR='./build'

check_deps() {

  RETRES=0
  while IFS= read -r line; do
    local DEPCMD=$line
    command -v $DEPCMD > /dev/null 2>&1
    DEPRES=$?
    if test $DEPRES -ne 0; then
      echo "Missing $DEPCMD, required for installation"
      RETRES=1
    else
      echo "$DEPCMD found"
    fi
    
  done < dep_list.txt
  return $RETRES 
}


process_dep_cmd() {
  local INCMD=$1
  local URLARG=$2
  local EXTARG=$3
  local SCRIPT=$4
  
  case $INCMD in

    git )
      git clone $URLARG $BUILDDIR/$EXTARG
      bash scripts/$SCRIPT $BUILDDIR
    ;;

    curl )
      curl $URLARG > $EXTARG
      bash scripts/$SCRIPT $BUILDDIR
    ;;

    *)
    echo "Unknown Command"
    ;;
  esac 
}

# Checks the command dependencies
check_deps
CAN_INSTALL=$?

if test $CAN_INSTALL -ne 0; then
  echo "Unable to install rottnest, missing commands/dependencies required"
  exit 1
fi

# Sets up pyenv
echo "Activating venv"
source $BUILDDIR/venv/bin/activate
echo "Installing python 3.11 with pyenv"
pyenv install 3.11
eval "$(pyenv init -)"
pyenv global 3.11

# Sets up the build directory and virtualenv
echo "Setting up virtual environment in $BUILDDIR/venv"
virtualenv $BUILDDIR/venv



# Reads in the csv file which has a list of dependencies and what-not to
# process and have a bespoke script for

while IFS= read -r line; do
  DEPNAME=$(echo $line | cut -d',' -f1)
  CMDKIND=$(echo $line | cut -d',' -f2)
  REPOURL=$(echo $line | cut -d',' -f3)
  ESCRIPT=$(echo $line | cut -d',' -f4)
  EXTRARG=$(echo $line | cut -d',' -f5)

  process_dep_cmd "$CMDKIND" "$REPOURL" "$EXTRARG" "$ESCRIPT"
  #echo "process_dep_cmd $CMDKIND $REPOURL $EXTRARG $ESCRIPT"
  #sleep 1
  PROCRES=$?

  if test $PROCRES -ne 0; then
    echo "Aborting"
    exit 1
  fi

done < install_list.csv
