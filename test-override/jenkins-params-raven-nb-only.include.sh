#!/bin/sh
# Sample Jenkins params override script to only run Raven notebooks
# with the proper --nbval-lax switch.
# Intended for param CONFIG_PARAMETERS_SCRIPT_URL.

# Disable default repos.
TEST_PAVICS_SDI_REPO="false"
TEST_FINCH_REPO="false"
TEST_PAVICS_LANDING_REPO="false"
TEST_LOCAL_NOTEBOOKS="false"

# Enable raven repos.
TEST_RAVEN_REPO="true"
TEST_RAVENPY_REPO="true"

# Raven nbs outputs are not fully up-to-date or regexed escaped properly like
# the other default nbs so need --nbval-lax for the moment.
#PYTEST_EXTRA_OPTS="$PYTEST_EXTRA_OPTS --nbval-lax"

# Set different test branch if required.
#RAVEN_BRANCH=""
#RAVENPY_BRANCH=""
