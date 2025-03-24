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

## How to run

The `install.sh` script will generate a `build` folder locally when assemblying
the project

Example:
```sh
bash install.sh ./build
```
