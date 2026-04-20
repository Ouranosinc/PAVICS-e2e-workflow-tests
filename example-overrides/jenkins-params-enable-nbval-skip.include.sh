#!/bin/sh
#
# Jenkins params override script to demonstrate pre processing
# and on-the-fly CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL file creation.
#
# This script is intended for param CI_OVERRIDE_CONFIG_PARAMETERS_SCRIPT_URL.

# Scenario: we want to actually run notebook cells marked with NBVAL_SKIP.

# Create CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL file on-the-fly to perform pre
# processing to replace NBVAL_SKIP with NBVAL_IGNORE_OUTPUT.

CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL="/tmp/ci-override-config-override.include.sh"

# Need to export so it is visible in 'runtest'.
export CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL

# Populate the content of our CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL.
echo '
#!/bin/sh
# Config override script to perform pre and post processing.

sed -i "s/NBVAL_SKIP/NBVAL_IGNORE_OUTPUT/g" $NOTEBOOKS
' > "$CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL"
