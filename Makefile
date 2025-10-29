TARGET_REMOTE=git@github.com:QSI-BAQS

.PHONY: install fetch build clean delete update test snapshot load-snapshot

BASE=rottnest

LIB_TARG=libs
LIBS:=${BASE}/${LIB_TARG}

APPLICATION_TARG=applications
APPLICATIONS:=${BASE}/${APPLICATION_TARG}

ARCHITECTURE_TARG=architectures
ARCHITECTURES:=${BASE}/${ARCHITECTURE_TARG}

EXECUTABLE_TARG=executables
EXECUTABLES:=${BASE}/${EXECUTABLE_TARG}

UTIL_TARG=utils
UTILS:=${BASE}/${UTIL_TARG}


# ---[ Load component lists ]---
LIB_REPOS=$(file < repolist/${LIB_TARG})
LIB_TARGETS=$(patsubst %, ${LIBS}/%, ${LIB_REPOS})

APPLICATION_REPOS=$(file < repolist/${APPLICATION_TARG})
APPLICATION_TARGETS=$(patsubst %,${APPLICATIONS}/%,${APPLICATION_REPOS})

ARCHITECTURE_REPOS=$(file < repolist/${ARCHITECTURE_TARG})
ARCHITECTURE_TARGETS=$(patsubst %,${ARCHITECTURES}/%,${ARCHITECTURE_REPOS})

EXECUTABLE_REPOS=$(file < repolist/${EXECUTABLE_TARG})
EXECUTABLE_TARGETS=$(patsubst %,${EXECUTABLES}/%,${EXECUTABLE_REPOS})

UTIL_REPOS=$(file < repolist/${UTIL_TARG})
UTIL_TARGETS=$(patsubst %,${UTILS}/%,${UTIL_REPOS})

ALL_REPOS:=${LIB_REPOS} ${APPLICATION_REPOS} ${ARCHITECTURE_REPOS} ${EXECUTABLE_REPOS} ${UTIL_REPOS}
ALL_TARGETS:=${LIB_TARGETS} ${APPLICATION_TARGETS} ${ARCHITECTURE_TARGETS} ${EXECUTABLE_TARGETS} ${UTIL_TARGETS}


# ---[ Command Generation ]---
# Fetch the given component
FETCH_SYMBOL=__fetch
FETCH_CMDS=$(patsubst %,%${FETCH_SYMBOL},${ALL_TARGETS})

# Uninstall the given component
CLEAN_SYMBOL=__clean
CLEAN_CMDS=$(patsubst %,%${CLEAN_SYMBOL},${ALL_TARGETS})

# Build AND INSTALL the given component
BUILD_SYMBOL=__build
BUILD_CMDS=$(patsubst %,%${BUILD_SYMBOL},${ALL_TARGETS})

# Update the given component (installs over previous versions)
UPDATE_SYMBOL=__update
UPDATE_CMDS=$(patsubst %,%${UPDATE_SYMBOL},${ALL_TARGETS})

# Run tests for the given component
TEST_SYMBOL=__test
TEST_CMDS=$(patsubst %,%${TEST_SYMBOL},${ALL_TARGETS})


# ---[ Command Targets ]---
install: fetch build


# fetch : retrieve the latest version of each repo
fetch: ${FETCH_CMDS}
	@echo "--=[ Successfully fetched Rottnest components ]=--"

%${FETCH_SYMBOL}: FETCH_DEST=$(patsubst %${FETCH_SYMBOL},%,$@)
%${FETCH_SYMBOL}: FETCH_REPO=$(notdir ${FETCH_DEST})
%${FETCH_SYMBOL}:
	@echo "--=[ Fetching component ${FETCH_DEST} ]=--"
	@git clone ${TARGET_REMOTE}/${FETCH_REPO} ${FETCH_DEST} &>/dev/null || cd ${FETCH_DEST}; git fetch origin &>/dev/null && git checkout origin &>/dev/null
	@echo "--=[ Successfully fetched ${FETCH_DEST} ]=--"


# clean : uninstall each component
clean: ${CLEAN_CMDS}
	@echo "--=[ Rottnest successfully uninstalled ]=--"

%${CLEAN_SYMBOL}: CLEANING_TARGET=$(patsubst %${CLEAN_SYMBOL},%,$@)
%${CLEAN_SYMBOL}: FORCE
	@echo "--=[ Uninstalling component ${CLEANING_TARGET} ]=--"
	@${MAKE} -C ${CLEANING_TARGET} clean || echo "${CLEANING_TARGET} was not installed"


# delete : remove all components from the device
# 		   cleans first to ensure the components do not remain
#          installed
delete: clean
	@rm -rf ${BASE}


# build : build and actually install each component
build: ${BUILD_CMDS}
	@echo "--=[ Rottnest successfully installed ]=--"

%${BUILD_SYMBOL}: BUILD_DEST=$(patsubst %${BUILD_SYMBOL},%,$@)
%${BUILD_SYMBOL}: FORCE
	@echo "--=[ Installing component ${BUILD_DEST} ]=--"
	@${MAKE} -C ${BUILD_DEST} build
	@echo "--=[ Component ${BUILD_DEST} successfully installed ]=--"


# update : delegate update to each component
# 	       may be equivalent to `fetch build` in some cases
update: ${UPDATE_CMDS}
	@echo "--=[ Rottnest sccessfully updated ]=--"

%${UPDATE_SYMBOL}: UPDATE_TARGET=$(patsubst %${UPDATE_SYMBOL},%,$@)
%${UPDATE_SYMBOL}: FORCE
	@echo "--=[ Updating component ${UPDATE_TARGET} ]=--"
	@${MAKE} -C ${UPDATE_TARGET} update
	@echo "--=[ Component ${UPDATE_TARGET} successfully updated ]=--"


# test : run tests for each component
test: ${TEST_CMDS}
	@echo "--=[ All tests passed ]=--"

%${TEST_SYMBOL}: TEST_TARGET=$(patsubst %${TEST_SYMBOL},%,$@)
%${TEST_SYMBOL}: FORCE
	@echo "--=[ Testing component ${TEST_TARGET} ]=--"
	@${MAKE} -C ${TEST_TARGET} test
	@echo "--=[  Component ${TEST_TARGET} passed all tests ]=--"


# snapshot : save the current git revisions in use
snapshot:
	@echo "--=[ Saving snapshot of current install ]=--"
	$(file >rottnest_snapshot)
	$(foreach target,${ALL_TARGETS}, \
		$(file >>rottnest_snapshot,${target}@$(shell cd ${target}; git rev-parse HEAD)))
	@echo "--=[ Snapshot saved to ./rottnest_snapshot ]=--"


# load-snapshot : restore from the local snapshot file
load-snapshot:
ifeq ($(shell [[ -e rottnest_snapshot ]]; echo $$?),1)
	@echo "--=< No snapshot to load from >=--"
else
	@echo "--=[ Restoring snapshot state ]=--"
	$(foreach target_state,$(file <rottnest_snapshot), \
		$(shell cd $(word 1,$(subst @, ,${target_state})); git checkout $(word 2,$(subst @, ,${target_state})) &>/dev/null))
	@echo "--=[ Loaded snapshot state ]=--"
	@echo "--=[ Uninstalling and reinstalling from snapshot ]=--"
	${MAKE} clean
	${MAKE} build
	@echo "--=[ Successfully installed from snapshot ]=--"
endif



# Dummy rule to allow forcing w/out .PHONY
# (which blocks implicit rules)
FORCE:
