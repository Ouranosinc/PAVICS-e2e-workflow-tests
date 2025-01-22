# Overview

Please include a summary of the changes and which issues is fixed. Please also include relevant motivation and context. List any dependencies that are required for this change.

This PR fixes [issue id](url)

<!-- NOTE: Remember to tag 'release-py###-######' on the commit of this merge. -->


## Changes

- Adds...
- Jupyter env changes:
  - Change 1 (related PR url)
  - Change 2 (related PR url)
  - Relevant changes (alphabetical order):
```diff
<   - somelib=0.8.1=pyh6c4a22f_1
>   - somelib=0.8.4=pyh1a96a4e_0

(...)

```


## Test

- Deployed as "beta" image in production for bokeh visualization performance regression testing.
- Manual test notebook https://github.com/Ouranosinc/PAVICS-landing/blob/master/content/notebooks/climate_indicators/PAVICStutorial_ClimateDataAnalysis-5Visualization.ipynb for bokeh visualization performance and it looks fine.
- Jenkins build:
  - Default notebooks https://github.com/Ouranosinc/PAVICS-e2e-workflow-tests/blob/NEW-release-py###-######/docker/saved_buildout/jenkins-buildlogs-default.txt
  - Raven notebooks https://github.com/Ouranosinc/PAVICS-e2e-workflow-tests/blob/NEW-release-py###-######/docker/saved_buildout/jenkins-buildlogs-raven.txt


## Related Issue / Discussion

- Matching notebook fixes:
  - Pavics-sdi: PR url
  - Finch: PR url
  - PAVICS-landing: PR url
  - RavenPy: PR url
  - (...)

- Deployment to PAVICS: PR url

- Jenkins-config changes for new notebooks: PR url

- Other issues found while working on this one
  - Issue 1 URL
  - Issue 2 URL
  - (...)

- Previous release: PR url


## Additional Information

Full diff conda env export:
https://github.com/Ouranosinc/PAVICS-e2e-workflow-tests/compare/PREVIOUS-release-py###-######...NEW-release-py###-######

Full new conda env export:
https://github.com/Ouranosinc/PAVICS-e2e-workflow-tests/blob/NEW-release-py###-######/docker/saved_buildout/conda-env-export.yml

DockerHub build log
https://github.com/Ouranosinc/PAVICS-e2e-workflow-tests/blob/NEW-release-py###-######/docker/saved_buildout/docker-buildlogs.txt
