#!/bin/sh
#
# Sample Jenkins params override script to demonstrate running new notebooks
# from an external repo and on-the-fly CONFIG_OVERRIDE_SCRIPT_URL file creation.
#
# This script is intended for param CONFIG_PARAMETERS_SCRIPT_URL.

# Scenario: we want to run notebooks from an external repo, unknown to current Jenkins config.
# https://github.com/roocs/rook/tree/master/notebooks/*.ipynb

# Disable all existing default repos to avoid downloading them and running them.
TEST_PAVICS_SDI_REPO="false"
TEST_FINCH_REPO="false"
TEST_PAVICS_LANDING_REPO="false"
TEST_LOCAL_NOTEBOOKS="false"

# Set new external repo vars.  Need 'export' so CONFIG_OVERRIDE_SCRIPT_URL can see them.
export ROOK_REPO="roocs/rook"
export ROOK_BRANCH="master"

# Not checking for expected output, just checking whether the code can run without errors.
PYTEST_EXTRA_OPTS="$PYTEST_EXTRA_OPTS --nbval-lax"

# Create CONFIG_OVERRIDE_SCRIPT_URL file on-the-fly to run the notebooks from
# our external repo.

CONFIG_OVERRIDE_SCRIPT_URL="/tmp/custom-repos.include.sh"

# Populate the content of our CONFIG_OVERRIDE_SCRIPT_URL.
echo '
#!/bin/sh
# Sample config override script to run new notebooks from new external repo.

# Replicate processing steps in 'testall' script.

# Download the external repo.
downloadgithubrepos $ROOK_REPO $ROOK_BRANCH

# Prep vars for including new nbs in nb list to test.
ROOK_REPO_NAME="$(extract_repo_name "$ROOK_REPO")"
ROOK_DIR="$(sanitize_extracted_folder_name "${ROOK_REPO_NAME}-${ROOK_BRANCH}")"

delete_files_confusing_pytest "$ROOK_DIR"

# Set new nbs as nb list to test.
NOTEBOOKS="$ROOK_DIR/notebooks/*.ipynb"
' > "$CONFIG_OVERRIDE_SCRIPT_URL"
