# Overview

<!-- Please include a summary of the changes and which issues is fixed. Please also include relevant motivation and context. List any dependencies that are required for this change. -->

This PR fixes [issue id](URL_HERE) by [explain how it fixes the issue]. It also includes [any other relevant changes].

<!-- NOTE: Remember to tag 'release-py###-######' on the commit of this merge. -->

## Changes

- Adds...
- Jupyter env changes:
  - Change 1 
    - _Related PR URL_
  - Change 2 
    - _Related PR URL_
  - Relevant changes (alphabetical order):
```diff
<   - somelib=0.8.1=pyh6c4a22f_1
>   - somelib=0.8.4=pyh1a96a4e_0

(...)
```

## Testing Checklist

- [ ] Deployed as "beta" image in production for bokeh visualization performance regression testing.
- [ ] Manually tested notebook https://github.com/Ouranosinc/PAVICS-landing/blob/master/content/notebooks/climate_indicators/PAVICStutorial_ClimateDataAnalysis-5Visualization.ipynb for bokeh visualization performance.
- [ ] Committed the Jenkins build log to this Pull Request: https://github.com/Ouranosinc/PAVICS-e2e-workflow-tests/blob/NEW-release-py###-######/docker/saved_buildout/jenkins-buildlogs-default.txt

## Related Issue / Discussion

- Matching notebook fixes:
  - pavics-sdi: _PR URL_
  - finch: _PR URL_
  - PAVICS-landing: _PR URL_
  - RavenPy: _PR URL_
  - (...)

- Deployment to PAVICS: _PR URL_

- Jenkins-config changes for new notebooks: _PR URL_

- Other issues found while working on this one
  - _Issue 1 URL_
  - _Issue 2 URL_
  - (...)

- Previous release: _PR URL_

## Additional Information

Full diff of the conda env export:
https://github.com/Ouranosinc/PAVICS-e2e-workflow-tests/compare/PREVIOUS-release-py###-######...NEW-release-py###-######

Full new conda env export:
https://github.com/Ouranosinc/PAVICS-e2e-workflow-tests/blob/NEW-release-py###-######/docker/saved_buildout/conda-env-export.yml

DockerHub build log:
https://github.com/Ouranosinc/PAVICS-e2e-workflow-tests/blob/NEW-release-py###-######/docker/saved_buildout/docker-buildlogs.txt
