# Rottnest

## Installation

### Dependencies

The Rottnest installer requires the following:

- Python 3.11
- pip
- GNU Make (xCode Make might work, but is not officially supported)
- gcc or clang
- rustc
- cargo
- npm

When installing Rottnest, it will install some pip packages. The installer does not create or interact with Python virtual environments. If you wish to install the packages inside a virtual environment, please ensure the environment is activated before running the installer.


The components also have their own runtime dependencies. Most components handle the installation of their own dependencies. However, the following must be installed independently:

- Apptainer
- Docker
- Singularity
- postgres
- vite

Note that Rottnest-Py automatically installs Gridsynth. This involves installing `ghc 8.6.5` and `cabal 2.4.1.0` using `ghcup`, and so requires pulling and executing the Haskell installer script in the user's current environment.


### Running the Installer

Rottnest's installation is handled with `make`. The Makefile provides the following targets:

- `install` : the default, fetches and installs all components
- `fetch` : fetches components without installing them
- `build` : builds and installs components without fetching them
- `clean` : uninstalls all components
- `delete` : uninstalls all components, and removes the files from the system
- `test` : runs tests for all components (requires that they have already been installed)
- `update` : updates all components to their latest versions
- `snapshot` : saves the current versions of all components to `./rottnest_snapshot`, overwriting the previous snapshot if there is one
- `load-snapshot` : loads the component versions specified by `./rottnest_snapshot`, may require running `fetch` first

For most situations, running
```
$> make install
```
will be sufficient.


## Running the Components

<TODO>
