ROTTNEST_REMOTE=git@github.com:QSI-BAQS

.PHONY: install fetch build clean delete update test snapshot load-snapshot reset-snapshot

BASE=rottnest

LIB_DIR=libs
LIBS:=${BASE}/${LIB_DIR}

APPLICATION_DIR=applications
APPLICATIONS:=${BASE}/${APPLICATION_DIR}

ARCHITECTURE_DIR=architectures
ARCHITECTURES:=${BASE}/${ARCHITECTURE_DIR}

EXECUTABLE_DIR=executables
EXECUTABLES:=${BASE}/${EXECUTABLE_DIR}

UTIL_DIR=utils
UTILS:=${BASE}/${UTIL_DIR}


# ---[ Load component lists ]---
LIB_REPOS=$(file < repolist/${LIB_DIR})
LIB_TARGETS=$(patsubst %,${LIBS}/%,${LIB_REPOS})

APPLICATION_REPOS=$(file < repolist/${APPLICATION_DIR})
APPLICATION_TARGETS=$(patsubst %,${APPLICATIONS}/%,${APPLICATION_REPOS})

ARCHITECTURE_REPOS=$(file < repolist/${ARCHITECTURE_DIR})
ARCHITECTURE_TARGETS=$(patsubst %,${ARCHITECTURES}/%,${ARCHITECTURE_REPOS})

EXECUTABLE_REPOS=$(file < repolist/${EXECUTABLE_DIR})
EXECUTABLE_TARGETS=$(patsubst %,${EXECUTABLES}/%,${EXECUTABLE_REPOS})

UTIL_REPOS=$(file < repolist/${UTIL_DIR})
UTIL_TARGETS=$(patsubst %,${UTILS}/%,${UTIL_REPOS})

INTERNAL_REPOS:=${LIB_REPOS} ${APPLICATION_REPOS} ${ARCHITECTURE_REPOS} ${EXECUTABLE_REPOS} ${UTIL_REPOS}
INTERNAL_TARGETS:=${LIB_TARGETS} ${APPLICATION_TARGETS} ${ARCHITECTURE_TARGETS} ${EXECUTABLE_TARGETS} ${UTIL_TARGETS}


# ---[ Get external components ]---
# NOTE : For an external component, each command will default to the
# below definitions. These can be special-cased (more specific
# patterns override less specific patterns) if needed
EXTERNAL_DIR=externals
EXTERNALS:=${BASE}/${EXTERNAL_DIR}

EXTERNAL_REPOS=$(file < repolist/${EXTERNAL_DIR})
EXTERNAL_TARGETS=$(patsubst %,${BASE}/${EXTERNAL_DIR}/%,${EXTERNAL_REPOS})


ALL_REPOS:=${INTERNAL_REPOS} ${EXTERNAL_REPOS}
ALL_TARGETS:=${INTERNAL_TARGETS} ${EXTERNAL_TARGETS}



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


# ---[ Generic Command Targets ]---
install: fetch build


# fetch : perform the initial cloning of each component
fetch: ${FETCH_CMDS}
	@echo "--=[ Successfully fetched Rottnest components ]=--"

%${FETCH_SYMBOL}: FETCH_DEST=$(patsubst %${FETCH_SYMBOL},%,$@)
%${FETCH_SYMBOL}: FETCH_REPO=$(notdir ${FETCH_DEST})
%${FETCH_SYMBOL}:
	@echo "--=[ Fetching component ${FETCH_DEST} ]=--"
	@git clone ${ROTTNEST_REMOTE}/${FETCH_REPO} ${FETCH_DEST}
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
	@rm -f ./rottnest_snapshot
	@for target in ${ALL_TARGETS}; do echo $${target}@$$(cd $${target} && git rev-parse HEAD) >> ./rottnest_snapshot; done
	@echo "--=[ Snapshot saved to ./rottnest_snapshot ]=--"


# load-snapshot : restore from the local snapshot file
load-snapshot:
ifeq ($(shell [[ -e rottnest_snapshot ]]; echo $$?),1)
	@echo "--=< No snapshot to load from >=--"
else
	@echo "--=[ Restoring snapshot state ]=--"
# A no-op patsubst is done to turn \n -> spaces (as file does not do this automatically)
	@STATES="$(patsubst %,%,$(file <rottnest_snapshot))"; \
		for target_state in $$STATES; do \
			read DIR REV <<<$${target_state//@/\ }; \
			$$(cd "$$DIR" && git checkout "$$REV"); \
		done
	@echo "--=[ Loaded snapshot state ]=--"
	@echo "--=[ Uninstalling and reinstalling from snapshot ]=--"
	${MAKE} clean
	${MAKE} build
	@echo "--=[ Successfully installed from snapshot ]=--"
endif


# reset-snapshot : exits snapshot state (so that repos can be updated normally again)
reset-snapshot:
	@echo "--=[ Leaving snapshot state ]=--"
	@for target in ${ALL_TARGETS}; do $$(cd $${target} && git checkout -); done
	@echo "--=[ Successfully returned to latest ]=--"



# ---[ Special Cases for External Components ]---

# Pandora
# TODO : Either load a custom makefile or interface with theirs
${EXTERNALS}/pandora${FETCH_SYMBOL}: FETCH_DEST=$(patsubst %${FETCH_SYMBOL},%,$@)
${EXTERNALS}/pandora${FETCH_SYMBOL}: FETCH_REPO=$(notdir ${FETCH_DEST})
${EXTERNALS}/pandora${FETCH_SYMBOL}: FORCE
	@echo "--=[ Fetching component ${FETCH_DEST} ]=--"
	@git clone git@github.com:ioanamoflic/${FETCH_REPO} ${FETCH_DEST}
	@echo "--=[ Successfully fetched ${FETCH_DEST} ]=--"

${EXTERNALS}/pandora${CLEAN_SYMBOL}: FORCE
	@echo "This should clean up pandora"

${EXTERNALS}/pandora${BUILD_SYMBOL}: FORCE
	@echo "This should build pandora"

${EXTERNALS}/pandora${UPDATE_SYMBOL}: FORCE
	@echo "This should update pandora"

${EXTERNALS}/pandora${TEST_SYMBOL}: FORCE
	@echo "This should test pandora"


# Dummy rule to allow forcing w/out .PHONY
# (which blocks implicit rules)
.PHONY: FORCE
FORCE:
