ROTTNEST_REMOTE=git@github.com:QSI-BAQS
SHELL=/bin/bash

BOLD=\033[1m
END_STYLE=\033[0m

SUCCESS_TEXT:=${BOLD}\033[32m
FAIL_TEXT:=${BOLD}\033[31m

FATAL_MSG:=${FAIL_TEXT}[FATAL]${END_STYLE}
WARN_MSG:=${BOLD}[WARN]${END_STYLE}

.PHONY: all install fetch build clean delete update test snapshot load-snapshot reset-snapshot preflight-checks

# Default target
all: install


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


EXTERNAL_WRAPPERS=external_wrappers


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


# Trivial "must-have" dependencies (more complex requirements
# are handled explicitly in preflight-checks)
COMMAND_DEPS=curl tar git python3 ghc cabal pip npm cargo docker
CMD_CHECK_SYMBOL=__cmd_check
COMMAND_CHECKERS=$(patsubst %,%${CMD_CHECK_SYMBOL},${COMMAND_DEPS})

%${CMD_CHECK_SYMBOL}: CHECK_CMD=$(patsubst %${CMD_CHECK_SYMBOL},%,$@)
%${CMD_CHECK_SYMBOL}:
	@${CHECK_CMD} --version > /dev/null 2>&1 || (printf "${FATAL_MSG} Missing required command: ${CHECK_CMD}\n" && false)

# ---[ Preflight Checks ]---
# Catch errors now instead of mid build.
preflight-checks: ${COMMAND_CHECKERS}
	@${MAKE} --version | grep "GNU Make 4" > /dev/null 2>&1 || (printf "${FATAL_MSG} Incorrect version: ${MAKE} - $$(${MAKE} --version | head -n 1) (required 4.x)\n" && false)
	@python3 --version | grep "3.11" > /dev/null 2>&1 || (printf "${FATAL_MSG} Incorrect version: python3 - $$(python3 --version) (required 3.11)\n" && false)
	@gcc --version > /dev/null 2>&1 || clang --version > /dev/null 2>&1 || (printf "${FATAL_MSG} Missing required command: at least one of gcc or clang\n" && false)
	@apptainer --version > /dev/null 2>&1 || (printf "${WARN_MSG} Missing suggested command: apptainer\n")



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
install: preflight-checks fetch build
	@printf "${SUCCESS_TEXT}Successfully installed rottnest${END_STYLE}\n"

# fetch : perform the initial cloning of each component
fetch: preflight-checks ${FETCH_CMDS}
	@printf "${SUCCESS_TEXT}Successfully fetched rottnest components${END_STYLE}\n"

%${FETCH_SYMBOL}: FETCH_DEST=$(patsubst %${FETCH_SYMBOL},%,$@)
%${FETCH_SYMBOL}: FETCH_REPO=$(notdir ${FETCH_DEST})
%${FETCH_SYMBOL}:
	@printf "${BOLD}Fetching component ${FETCH_DEST}${END_STYLE}\n"
	@git clone ${ROTTNEST_REMOTE}/${FETCH_REPO} ${FETCH_DEST} || (printf "${FATAL_MSG} Failed to fetch ${FETCH_DEST}\n" && false)
	@printf "${SUCCESS_TEXT}Successfully fetched ${FETCH_DEST}${END_STYLE}\n\n"


# clean : uninstall each component
clean: ${CLEAN_CMDS}
	@printf "${SUCCESS_TEXT}Rottnest successfully uninstalled${END_STYLE}\n"

%${CLEAN_SYMBOL}: CLEANING_TARGET=$(patsubst %${CLEAN_SYMBOL},%,$@)
%${CLEAN_SYMBOL}: FORCE
	@printf "${BOLD}Uninstalling component ${CLEANING_TARGET}${END_STYLE}\n"
	@${MAKE} -C ${CLEANING_TARGET} clean || printf "${WARN_MSG} ${CLEANING_TARGET} was not installed\n"


# delete : remove all components from the device
# 		   cleans first to ensure the components do not remain
#          installed
delete: clean
	@rm -rf ${BASE}


# build : build and actually install each component
# 		  to enforce any ordering, list targets explicitly
build: preflight-checks ${EXTERNALS}/newsynth_patch${BUILD_SYMBOL} ${BUILD_CMDS}

%${BUILD_SYMBOL}: BUILD_DEST=$(patsubst %${BUILD_SYMBOL},%,$@)
%${BUILD_SYMBOL}: FORCE
	@printf "${BOLD}Installing component ${BUILD_DEST}${END_STYLE}\n"
	@${MAKE} -C ${BUILD_DEST} build || (printf "${FATAL_MSG} Failed to build ${BUILD_DEST}\n" && false)
	@printf "${SUCCESS_TEXT}Component ${BUILD_DEST} successfully installed${END_STYLE}\n\n"


# update : delegate update to each component
update: preflight-checks ${UPDATE_CMDS}

%${UPDATE_SYMBOL}: UPDATE_TARGET=$(patsubst %${UPDATE_SYMBOL},%,$@)
%${UPDATE_SYMBOL}: FORCE
	@printf "${BOLD}Updating component ${UPDATE_TARGET}${END_STYLE}\n"
	@${MAKE} -C ${UPDATE_TARGET} update || (printf "${FATAL_MSG} Failed to update ${UPDATE_TARGET}\n" && false)
	@printf "${SUCCESS_TEXT}Component ${UPDATE_TARGET} successfully updated${END_STYLE}\n\n"


# test : run tests for each component
test: preflight-checks ${TEST_CMDS}

%${TEST_SYMBOL}: TEST_TARGET=$(patsubst %${TEST_SYMBOL},%,$@)
%${TEST_SYMBOL}: FORCE
	@printf "${BOLD}Testing component ${TEST_TARGET}${END_STYLE}\n"
	@${MAKE} -C ${TEST_TARGET} test && echo "${SUCCESS_TEXT}Passed tests for ${TEST_TARGET}${END_STYLE}\n\n" || printf "${FAIL_TEXT}Tests for ${TEST_TARGET} did not pass${END_STYLE}\n"


# snapshot : save the current git revisions in use
snapshot: preflight-checks
	@printf "${BOLD}Saving snapshot of current install${END_STYLE}\n"
	@rm -f ./rottnest_snapshot
	@for target in ${ALL_TARGETS}; do echo $${target}@$$(cd $${target} && git rev-parse HEAD) >> ./rottnest_snapshot; done
	@printf "${SUCCESS_TEXT}Snapshot saved to ./rottnest_snapshot${END_STYLE}\n"


# load-snapshot : restore from the local snapshot file
load-snapshot: preflight-checks
ifeq ($(shell [[ -e rottnest_snapshot ]]; echo $$?),1)
	@printf "${FATAL_MSG}No snapshot to load from\n"
else
	@printf "${BOLD}Restoring snapshot state${END_STYLE}\n"
# A no-op patsubst is done to turn \n -> spaces (as file does not do this automatically)
	@STATES="$(patsubst %,%,$(file <rottnest_snapshot))"; \
		for target_state in $$STATES; do \
			read DIR REV <<<$${target_state//@/\ }; \
			echo $$(cd "$$DIR" && git checkout "$$REV"); \
		done
	@printf "${SUCCESS_TEXT}Loaded snapshot state${END_STYLE}\n"
	@printf "${BOLD}Uninstalling and reinstalling from snapshot${END_STYLE}\n"
	${MAKE} clean
	${MAKE} build
	@printf "${SUCCESS_TEXT}Successfully installed from snapshot${END_STYLE}\n"
endif


# reset-snapshot : exits snapshot state (so that repos can be updated normally again)
reset-snapshot: preflight-checks
	@printf "${BOLD}Leaving snapshot state${END_STYLE}\n"
	@for target in ${ALL_TARGETS}; do echo $$(cd $${target} && git checkout -); done
	@printf "${SUCCESS_TEXT}Successfully returned to latest${BOLD}\n"


# ---[ Includes for external components ]---
include ${EXTERNAL_WRAPPERS}/*/include


# Dummy rule to allow forcing w/out .PHONY
# (which blocks implicit rules)
.PHONY: FORCE
FORCE:
