#!/bin/sh
# Sample config override script to only run notebooks that hits GeoServer.
# Intended for param CONFIG_OVERRIDE_SCRIPT_URL.

# Have to be used together with TEST_NO_USE_PROD_DATA=1 (via EXTRA_TEST_ENV_VAR).

NEW_NB_LIST=""
for nb in $NOTEBOOKS; do
    if echo "$nb" | grep -i raven && grep -i -e 'import birdy' -e 'from birdy' $nb; then
        # Any Raven nb which import birdy will hit GeoServer.
        NEW_NB_LIST="$NEW_NB_LIST $nb"
    elif grep -i geoserver $nb; then
        # Any mention of GeoServer, 'geoserver/wfs'.
        NEW_NB_LIST="$NEW_NB_LIST $nb"
    fi
done
NOTEBOOKS="$NEW_NB_LIST"
