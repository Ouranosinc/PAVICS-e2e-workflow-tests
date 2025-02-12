#!/bin/sh
#
# Jenkins params override script to demonstrate excluding default
# notebooks and on-the-fly DEFAULT_CONFIG_OVERRIDE_SCRIPT_URL file creation.
#
# This script is intended for param DEFAULT_CONFIG_PARAMETERS_SCRIPT_URL.

# Scenario: we want to exclude some default notebooks that is known to not work
# or we do not need to generate the output at the end.

# Create DEFAULT_CONFIG_OVERRIDE_SCRIPT_URL file on-the-fly to run the notebooks
# from our external repo.

DEFAULT_CONFIG_OVERRIDE_SCRIPT_URL="/tmp/default-config-override.include.sh"

# Need to export so it is visible in 'runtest'.
export DEFAULT_CONFIG_OVERRIDE_SCRIPT_URL

# Populate the content of our DEFAULT_CONFIG_OVERRIDE_SCRIPT_URL.
echo '
#!/bin/sh
# Config override script to exclude default notebooks.

NEW_NB_LIST=""
for nb in $NOTEBOOKS; do
    if [ x"$nb" != x"$RAVENPY_DIR/docs/notebooks/HydroShare_integration.ipynb" ]; then
        NEW_NB_LIST="$NEW_NB_LIST $nb"
    fi
done
NOTEBOOKS="$NEW_NB_LIST"


# Select which notebooks to blacklist from generating output.
enable_resulting_nb() {
    nb="$1"
    if [ x"$nb" != x"$PAVICS_SDI_DIR/docs/source/notebooks/FAQ_dask_parallel" ] ||
       [ x"$nb" != x"$PAVICS_LANDING_DIR/content/notebooks/climate_indicators/PAVICStutorial_ClimateDataAnalysis-3Climate-Indicators" ]; then
        # Blacklist those notebooks.
        return 1
    else
        # Enable all the rest.
        return 0
    fi
}
' > "$DEFAULT_CONFIG_OVERRIDE_SCRIPT_URL"
