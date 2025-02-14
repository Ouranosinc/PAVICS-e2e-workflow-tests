#!/bin/sh
# Sample Jenkins params override script to demonstrate on-the-fly
# CONFIG_OVERRIDE_SCRIPT_URL file creation.
# This script is intended for param CONFIG_PARAMETERS_SCRIPT_URL.

# Scenario: we only want to run 2 specific Raven notebooks:
# * 10_Data_assimilation.ipynb
# * 11_Climatological_ESP_forecasting.ipynb

# The beginning is same as jenkins-params-raven-nb-only.include.sh so just
# re-use it.

# Log content of override script for traceability.
cat test-override/jenkins-params-raven-nb-only.include.sh

. test-override/jenkins-params-raven-nb-only.include.sh

# Then we create CONFIG_OVERRIDE_SCRIPT_URL file on-the-fly to filter for the 2
# notebooks that we want.

CONFIG_OVERRIDE_SCRIPT_URL="/tmp/specific-raven-nb.include.sh"

# export so it is visible by 'runtest'.
export CONFIG_OVERRIDE_SCRIPT_URL

echo '
#!/bin/sh
# Sample config override script to only run 2 specific raven notebooks.

NEW_NB_LIST=""
for nb in $NOTEBOOKS; do
    if echo "$nb" | grep -i -e 10_Data_assimilation -e 11_Climatological_ESP_forecasting; then
        NEW_NB_LIST="$NEW_NB_LIST $nb"
    fi
done
NOTEBOOKS="$NEW_NB_LIST"
' > "$CONFIG_OVERRIDE_SCRIPT_URL"
