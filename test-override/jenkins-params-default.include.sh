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

# Disable nb not required to generate output to speed up run time.
pre_saving_resulting_nb() {
    NEW_RESULTING_NB=""
    for nb in $RESULTING_NOTEBOOKS; do
        if [ x"$nb" != x"$PAVICS_SDI_DIR/docs/source/notebooks/FAQ_dask_parallel.ipynb" ] &&
           [ x"$nb" != x"$PAVICS_LANDING_DIR/content/notebooks/climate_indicators/PAVICStutorial_ClimateDataAnalysis-3Climate-Indicators.ipynb" ]; then
            NEW_RESULTING_NB="$nb"
        fi
    done
    RESULTING_NOTEBOOKS="$NEW_RESULTING_NB"
}
' > "$DEFAULT_CONFIG_OVERRIDE_SCRIPT_URL"
