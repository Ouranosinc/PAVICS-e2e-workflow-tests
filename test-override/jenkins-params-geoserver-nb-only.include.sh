#!/bin/sh
# Sample Jenkins params override script to only run notebooks that hit GeoServer.
# Intended for param CONFIG_PARAMETERS_SCRIPT_URL.

# Enable all repos so we can filter all for them for notebooks that hit GeoServer.
TEST_PAVICS_SDI_REPO="true"
TEST_FINCH_REPO="true"
TEST_PAVICS_LANDING_REPO="true"
TEST_LOCAL_NOTEBOOKS="true"
TEST_RAVEN_REPO="true"
TEST_RAVENPY_REPO="true"

# Force use the local GeoServer, to test the local GeoServer.  Otherwise the
# production GeoServer will be used, which defeat the purpose of the test.
# Need to 'export' because TEST_NO_USE_PROD_DATA was meant to be used in
# EXTRA_TEST_ENV_VAR Jenkins build param.  TEST_NO_USE_PROD_DATA is not
# directly one of Jenkins build param.  Build params do not need 'export'.
export TEST_NO_USE_PROD_DATA=1

# Chain with the other override script to filter the notebooks that hit
# GeoServer only.
CONFIG_OVERRIDE_SCRIPT_URL="https://raw.githubusercontent.com/Ouranosinc/PAVICS-e2e-workflow-tests/master/test-override/geoserver-nb-only.include.sh"

# export so it is visible by 'runtest'.
export CONFIG_OVERRIDE_SCRIPT_URL

# Set different test branch if required.
#PAVICS_SDI_BRANCH=""
#FINCH_BRANCH=""
#PAVICS_LANDING_BRANCH=""
#RAVEN_BRANCH=""
#RAVENPY_BRANCH=""
