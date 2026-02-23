# Rottnest

## Installation

**Any Python environment setup (eg. `venv`, `conda`, etc.) must be done BEFORE running the installer.** The installer will use `pip` - ensure you have an environment in which `pip` can successfully install packages.

### Dependencies

The Rottnest installer requires the following:

- curl and tar
- Python 3.11
- pip
- GNU Make v4 (note that v3, the default on Mac, will not work)
- gcc or clang
- rustc
- cargo
- npm
- ghc and cabal

TODO : ghc and cabal (maybe more?) local installers

When installing Rottnest, it will install some pip packages. The installer does not create or interact with Python virtual environments. If you wish to install the packages inside a virtual environment, please ensure the environment is activated before running the installer.


The components also have their own runtime dependencies. Most components handle the installation of their own dependencies. However, the following must be installed independently:

- Apptainer
- Docker
- Singularity
- vite

TODO : Status of apptainer-less pandora w/ docker


### Running the Installer

**NOTE:** GNU Make v4 is required for the installation. For Mac users, this can be acquire via `brew install make`. The `brew` version of `make` is available as `gmake` - all use of `make` in the below commands should be replaced with `gmake` if using Homebrew on Mac.

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

TODO : Implement `make run`


## Makefile Variables

The following variables may prove useful, and are designed to be potentially set from the commandline:
- `ROTTNEST_REMOTE` : Should be the prefix for a `git` target. Can be changed to attempt to fetch Rottnest components from a different location (the naming must be identical to the main Rottnest upstream, and all components must be available)
- `IGNORE_DEPS` : Should be a space-separated list of dependencies to skip the checks for. eg. `IGNORE_DEPS="rustc cargo"` will not check if rust is installed before attempting to build.
- `SKIP_TARGETS` : Should be a space-separated list of targets to attempt to skip. Note that they will be skipped in their entirety (no fetch, build, or install). This applies to all exposed commands. eg. `SKIP_TARGETS=rottnest_js` will ensure that the frontend is not fetched or built. Note that not all targets can be successfully skipped.


## For Developers

Internally, the installer uses a series of templated Makefile targets to build, install, etc. components.

These targets often delegate to a per-component Makefile, meaning that all they have to do is call `${MAKE} -C <component directory> <recursive target>`.

The list of components is loaded from the files in `repolist`, which provide the names of the repositories to fetch components from (separated by spaces or newlines), organised into categories.

For each component, there are two things that are required:
- A way to acquire that component (eg. `git`)
- A way to then build, etc. that component with our interface


### Acquiring Components
If a component is internal (such that it can be fetched via `git` from the provided `ROTTNEST_REMOTE`), then it will automatically be covered by the existing template.

If a component is to be fetched from somewhere else, then a new target `${<category>}/<component name>__${FETCH_SYMBOL}` must be provided. This target should be provided in the file `external_wrappers/<component name>/include`, and will be automatically included as part of the main Makefile.


### Interfacing with Components
Once a component has been fetched, our interface of `clean`, `build`, `update`, `test` must be used to manage that component. There are three main cases for a component:

#### Component provides a Makefile that implements our interface
In this case, nothing needs to be done.

#### Component lacks a Makefile
In this case, the easiest solution is to create our own Makefile for that component (that wraps whatever build system it does use in our interface), and copy that Makefile into the component's directory during the `fetch` step. The Makefile should be placed at `external_wrappers/<component name>/Makefile`, and should implement `build`, `update`, `test` and `clean`.

#### Component has a Makefile that does not implement our interface
In this case, the `include` for that component should also expose targets for `${category}/<component name>__${BUILD_SYMBOL}`, `__${UPDATE_SYMBOL}`, `__${TEST_SYMBOL}` and `__${CLEAN_SYMBOL}`. These can then manually call whatever recursive Makefile targets perform the equivalent roles in the component's Makefile.
