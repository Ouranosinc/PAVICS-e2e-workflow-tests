#!/bin/sh
#
# Jenkins params override script to demonstrate pre and post processing
# and on-the-fly CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL file creation.
#
# This script is intended for param CI_OVERRIDE_CONFIG_PARAMETERS_SCRIPT_URL.

# Scenario: we want to test notebooks when the checkout is fully read-only.

# Create CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL file on-the-fly to perform pre
# and post processing to turn on and off read-only checkout.

CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL="/tmp/ci-override-config-override.include.sh"

# Need to export so it is visible in 'runtest'.
export CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL

# Populate the content of our CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL.
echo '
#!/bin/sh
# Config override script to perform pre and post processing.

# For artifact archiving steps, have to do this in advance when we still have write-access
# because next step we will make everything read-only.
mkdir buildout

# Read-only in checkout to emulate read-only tutorial-notebooks/ dir on PAVICS.
chmod a-w -R .

# So we do not break the artifact archiving step.
chmod ug+w buildout

post_runtest() {
  # Restore write-access so subsequent build request "checkout cleanup" step works.
  chmod ug+w -R .
}
' > "$CI_OVERRIDE_CONFIG_OVERRIDE_SCRIPT_URL"
