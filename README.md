# MetaRott

This is a metapackage for rottnest that will attempt to download and install all
necessary software and packages to run.

## Dependencies for Metarott

Ahh yes! Dependencies for the meta-packaging system. That is what we need!

* virtualenv
* apptainer
* docker
* pyenv
* rustc
* gcc

This does not cover the dependencies that are part of the rest of the suite, please look at the individual projects and their dependencies


## How to run

The `install.sh` script will generate a `build` folder locally when assemblying
the project

Example:
```sh
bash install.sh
```


## Running the projects

You can choose to use `run.sh` or you can individually run the following commands:

1. (Pandora) `bash run_apptainer.sh main.py default_config fh 10`, database gets started and is accessible

2. (RottnestPy) `python src/rottnest/server/server.py`, runs the backend server to serve data and process it

3. (Rottnest) `npm dev run`, will run the frontend and allow the user to interact with it 
