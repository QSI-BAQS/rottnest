# Rottnest 

This is a metapackage for rottnest that will attempt to download and install all
necessary software and packages to run.

## Dependencies for Rottnest 

Ahh yes! Dependencies for the meta-packaging system. That is what we need!

* Python 3.11
* GNU Make
* gcc or clang
* rustc
* postgres
* npm
* vite

Individual repos may require their own dependencies, some repos handle installation independently, others do not.
Here are some common dependencies.

* apptainer
* docker
* singularity

This does not cover the dependencies that are part of the rest of the suite, please look at the individual projects and their dependencies

Gridsynth requires Haskell and Cabal as dependencies, this is handled within the `rottnest_py` repo.
It is worth noting that the default behaviour is to pull and execute the Haskell compiler installation script in the user's current environment. 
This is done to obtain the correct versions for this software:
- GHC: 8.6.5 
- Cabal: 2.4.1.0 


## Building the system 

The system uses a `makefile` interface.

Simply running `make` will attempt to clone and install all repostories in the project.

- `install` : Installs all packages 
- `test` : Runs tests in all package 
- `update`: Updates all packages 
- `clean`: Removes all packages

In addition to this we expose per-module makefile commands:  

- <reponame> : Clones and builds that sub-repository 
- <reponame>__build : Builds and installs that sub-repository
- <reponame>__test : Runs tests on  that sub-repository
- <reponame>__update : Pulls and re-installs that sub-repository
- <reponame>__clean : Cleans and uninstalls that sub-repository


## Running the projects

1. (Pandora) `bash run_apptainer.sh main.py default_config`, database gets started and is accessible

2. (rottnest_py) `python src/rottnest/server/server.py`, runs the backend server to serve data and process it

3. (rottnest_js) `npm dev run`, will run the frontend and allow the user to interact with it 
