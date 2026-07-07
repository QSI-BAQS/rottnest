# Rottnest

## Installation

### Mac

To install on Mac, from the current directory please run `./distro_scripts/mac/mac_setup.sh`
- The script requires Homebrew to install Rottnest's dependencies
- The script requires that you have `python` installed, and that the version of `python` on `PATH` is `python 3.11`


### Ubuntu

To install on Ubuntu;
- Please either;
    - From the current directory, run `./distro_scripts/ubuntu/ubuntu_apt_helper.sh` as root. This will use `apt` to install most of Rottnest's dependencies
    - Install the dependencies (listed below) yourself
- Then, from the current directory, run `./distro_scripts/ubuntu/ubuntu_setup.sh` (not as root). This will install Rottnest.
    - The script requires that you have `python` installed, and that the version of `python` on `PATH` is `python 3.11`


### Other Linux Distributions

To install on another Linux distribution, please install the dependencies listed below, and then run `make install`. Note that the installation will install `pip` packages - please ensure you have configured your python environment as desired before running the installer.


## Running

To run Rottnest, please use the `./run_rottnest.sh` script. It requires that you have Firefox, Chrome or Safari installed.


## Dependencies

The Rottnest installer requires the following:

- curl and tar
- python 3.11
- pip
- GNU Make v4 (note that v3, the default on Mac, will not work)
- gcc or clang
- rustc
- cargo
- npm
- ghc and cabal
    - These **must** be installed with `ghcup`, not via a system package manager.

The components also have their own runtime dependencies. Most components handle the installation of their own dependencies. However, the following must be installed independently:

- Apptainer [OPTIONAL, not available on Mac]
- Docker
- vite
