#!/bin/sh
#
# Sample Jenkins params override script to demonstrate running new notebooks
# from an external repo and on-the-fly CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL file creation.
#
# This script is intended for param CI_OVERRIDE_CONFIG_PARAMETERS_SCRIPT_URL.

# Scenario: we want to run notebooks from an external repo, unknown to current Jenkins config.
# https://github.com/roocs/rook/tree/master/notebooks/*.ipynb

# Disable all existing default repos to avoid downloading them and running them.
TEST_PAVICS_SDI_REPO="false"
TEST_FINCH_REPO="false"
TEST_PAVICS_LANDING_REPO="false"
TEST_LOCAL_NOTEBOOKS="false"
TEST_RAVEN_REPO="false"
TEST_RAVENPY_REPO="false"

# Set new external repo vars.  Need 'export' so CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL can see them.
export ROOK_REPO="roocs/rook"
export ROOK_BRANCH="main"

# Hijack PAVICS_SDI fields for interractive build request ROOK override.
[ x"$PAVICS_SDI_REPO" != x"Ouranosinc/pavics-sdi" ] && ROOK_REPO="$PAVICS_SDI_REPO"
[ x"$PAVICS_SDI_BRANCH" != x"master" ] && ROOK_BRANCH="$PAVICS_SDI_BRANCH"

# Not checking for expected output, just checking whether the code can run without errors.
PYTEST_EXTRA_OPTS="$PYTEST_EXTRA_OPTS --nbval-lax"

# Create CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL file on-the-fly to run the notebooks from
# our external repo.

CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL="/tmp/ci-override-custom-repos.include.sh"

# export so it is visible by 'runtest'.
export CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL

# Populate the content of our CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL.
echo '
#!/bin/sh
# Sample config override script to run new notebooks from new external repo.

# Replicate processing steps in 'testall' script.

# Download the external repo.
downloadgithubrepos $ROOK_REPO $ROOK_BRANCH

# Prep vars for including new nbs in nb list to test.
ROOK_REPO_NAME="$(extract_repo_name "$ROOK_REPO")"
ROOK_DIR="$(sanitize_extracted_folder_name "${ROOK_REPO_NAME}-${ROOK_BRANCH}")"

# Set new nbs as nb list to test.
NOTEBOOKS="$ROOK_DIR/notebooks/*.ipynb"

# Sample demo override choose_artifact_filename: flat hierarchy
#
# Ex: when given 'pavics-sdi-master/docs/source/notebooks/regridding.ipynb',
# the current implementation will return
# 'pavics-sdi-master--regridding.ipynb', which means
# there will be
# "buildout/pavics-sdi-master--regridding.ipynb" and
# "buildout/pavics-sdi-master--regridding.output.ipynb"
#choose_artifact_filename() {
#    repo_branch="$(echo "$1" | sed "s@/.*@@")"
#    echo "${repo_branch}--$(basename "$1")"
#}

# Sample demo override post_runtest: create lots of artifacts for Jenkins to
# archive to test how Jenkins will display its archive page.
#post_runtest() {
#    for i in $(seq --equal-width 500); do
#        echo "file${i}" > "${BUILDOUT_DIR}/file${i}.ipynb"
#    done
#}
' > "$CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL"
