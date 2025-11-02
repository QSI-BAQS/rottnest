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

To install Rottnest for the first time, use;
```
make install
```
This will download all components, then build and install those components.


To update an already installed version of Rottnest;
```
make update
```

Before an update, you may wish to run;
```
make snapshot
```
to ensure you are able to rollback to the previous version if the update breaks something.

To restore a saved snapshot, use;
```
make load-snapshot
```
Note that this requires having already run at least `make fetch`.


The full set of supported commands are;
- `install` : delegates to `fetch` and then `build`
- `fetch` : downloads all components (does not update already downloaded components)
- `build` : builds and installs all components
- `update` : has each component update itself (fetch changes and install with those changes)
- `clean` : uninstalls all components
- `delete` : uninstalls all components, AND deletes all source files
- `test` : runs the Rottnest test suite
- `snapshot` : saves the current state of all installed components to `./rottnest_snapshot`, overwriting it if it already exists
- `load-snapshot` : loads the versions of the components specified by `./rottnest_snapshot`, uninstalling the current components and reinstalling from the snapshotted versions
- `reset-snapshot` : exits a snapshotted version, allowing typical updates to work again


## Running Rottnest

<TODO>


## For Developers

Internally, the installer uses a series of templated Makefile targets to build, install, etc. components.

These targets often delegate to a per-component Makefile, meaning that all they have to do is call `${MAKE} -C <component directory> <recursive target>`.

The list of components is loaded from the files in `repolist`, which provide the names of the repositories to fetch components from (separated by spaces or newlines), organised into categories.


To add a component that does is not internal, you will need to (at minimum) provide a new target `${EXTERNAL}/<component_name>${FETCH_SYMBOL}` which describes how to get the project.


With each repository we consider three cases:
### Repo implements the Makefile interface
- Nothing needs to be done after cloning the repository.


### Repo lacks a Makefile
- A repo-specific Makefile should live in this repository.
- As part of the cloning process that Makefile is then copied to the repository, satisfying the Makefile interface. 
- To satisfy this dependency the copied Makefile must implement `${CLEAN_SYMBOL}`, `${BUILD_SYMBOL}`, `${UPDATE_SYMBOL}`, `${TEST_SYMBOL}` (matching the above target) that directly interact with the external component


### Repo has a Makefile that does not implement the interface
- A repo-specific Makefile should live in this repository.
- Symbol-specific rules should be defined in that Makefile to implement the Makefile interface. 
That Makefile should then be `included` in the top level makefile, exposing the default rules. 
- To satisfy this dependency the included Makefile must implement `${CLEAN_SYMBOL}`, `${BUILD_SYMBOL}`, `${UPDATE_SYMBOL}`, `${TEST_SYMBOL}` (matching the above target) that directly interact with the external component

