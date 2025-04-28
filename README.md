# PAVICS-e2e-workflow-tests

Test user-level end-to-end workflow.

## Description

This repository ensures that the various Jupyter notebooks run without errors against the chosen [PAVICS server](https://github.com/bird-house/birdhouse-deploy/blob/master/birdhouse) and still produce the same output.

Resulting benefits:

* Jupyter notebooks that constitue the test suite can also double as documentation for the features provided to the end-users. More incentive to write more documentation and more tests since adding documentation means adding tests for free!

* This test suite is also useful during the upgrade of the system components since we are able to target different PAVICS servers with the same test suite.

* Jenkins (see [Jenkinsfile](Jenkinsfile)) is configured to run the test suite regularly, so we are able to detect regressions on servers or out-of-date output or code in the Jupyter notebooks. No more mismatched or outdated
  documentation!

* The runtime environment used by `Jenkins` is the exact same Jupyter environment deployed on PAVICS, ensuring we do not provide broken Jupyter environments to our users when the wish to try out the tutorial notebooks.

* Indirectly, this also serves as a monitoring tool for the servers. Standard monitoring tools normally just ensure the services are up and running. This will actually monitor that the most useful and frequently used user workflows are working end-to-end.

Built using the [nbval](https://github.com/computationalmodelling/nbval) Pytest plugin used to validate Jupyter notebooks.

Fully pre-configured turnkey deployment of `Jenkins` for this test suite can be found at https://github.com/Ouranosinc/jenkins-config.

## Launch Jupyter Notebook server using Binder
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/Ouranosinc/PAVICS-e2e-workflow-tests/master)

Click the Binder button above to launch a Jupyter Notebook server on Binder's cloud to test out all the notebooks in this test suite.

## Run locally

```shell
./launchcontainer  # get inside the container providing the runtime environment

./runtest  # run all notebooks under folder notebooks/
./runtest notebooks/hummingbird.ipynb  # run just 1 notebook

# download more repos containing notebooks (ex: pavics-sdi)
./downloadrepos

# run all notebooks from pavics-sdi
./runtest 'pavics-sdi-master/docs/source/notebooks/*.ipynb'

# run against another PAVICS host than pavics.ouranos.ca
# this assume the PAVICS host hardcoded inside the notebooks is pavics.ouranos.ca
PAVICS_HOST=host.example.com ./runtest

# provide more cli options to py.test
PYTEST_EXTRA_OPTS="--nbval-lax" ./runtest

# disable SSL cert verification for notebooks that support this flag
# useful together with PAVICS_HOST to hit hosts using self-signed SSL cert
DISABLE_VERIFY_SSL=1 ./runtest

# save output of test run as a notebook, ending with .outout.ipynb
# each input notebook will have corresponding .output.ipynb file under
#   buildout/ dir
# CAVEAT:
#   * run time is double as a different run is needed
#   * might not contain the exact same error as the original run since it's a
#     different run
SAVE_RESULTING_NOTEBOOK=true ./runtest
```

## Design considerations

As the runtime environment is provided via the Docker container, it is not required to create a conda env to run the tests.

By using the exact same Docker container as the one that Jenkins will use, you will be guarantied that if a notebook runs locally, it will also run successfully on Jenkins.

Therefore, we do not need to pin any versions in the conda [`environment.yml`](docker/environment.yml) file since the built docker image provides the pinned versions for reproducibility.

To encourage more notebooks written/contribution, which means more documentation and more tests, we have aimed to make it easy for users to add new notebooks. The test runner can even run notebooks from external repos (at present, notebooks from the [pavics-sdi](https://github.com/Ouranosinc/pavics-sdi/tree/master/docs/source/notebooks), [PAVICS-landing](https://github.com/Ouranosinc/PAVICS-landing/tree/master/content/notebooks), [RavenPy](https://github.com/CSHS-CWRA/RavenPy/tree/master/docs/notebooks) repositories are run and more can be added easily).

By default, we use regex to replace `pavics.ouranos.ca` with the hostname of the server under test to test all components of the server under test.  However, we do not perform this regex replacement step for `.ncml` links so `.ncml` links will come from our production server `pavics.ouranos.ca`. The reason here is that `.ncml` files
require a large amount of `.nc` matching files to be copied to the server under test so we want to avoid this setup burden for the server under test.  Typical `.nc` files will still have to be copied over so the Thredds component is tested.

## Adding more notebooks to tests

Add another `.ipynb` file under folder `notebooks/` and it'll be picked up by the runner.

## Start Jupyter Notebook to modify one of the notebooks

```shell
./launchnotebook [port]
```

Then follow the output to open the browser to your local Jupyter instance.

Example output:
```
[I 23:59:44.366 NotebookApp] Writing notebook server cookie secret to /home/jenkins/.local/share/jupyter/runtime/notebook_cookie_secret
[I 23:59:44.591 NotebookApp] Serving notebooks from local directory: /
[I 23:59:44.591 NotebookApp] The Jupyter Notebook is running at:
[I 23:59:44.591 NotebookApp] http://(ebe30a480ccf or 127.0.0.1):8890/?token=22fc0be94eb948977fc235b588116c670beafde4374d8de8
[I 23:59:44.591 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[C 23:59:44.595 NotebookApp]

    To access the notebook, open this file in a browser:
        file:///home/jenkins/.local/share/jupyter/runtime/nbserver-1-open.html
    Or copy and paste one of these URLs:
        http://(ebe30a480ccf or 127.0.0.1):8890/?token=22fc0be94eb948977fc235b588116c670beafde4374d8de8
```

So you would open:`http://localhost:8890/?token=22fc0be94eb948977fc235b588116c670beafde4374d8de8`
Then navigate to: `http://localhost:8890/tree/home/lvu/repos/PAVICS-e2e-workflow-tests/notebooks`
if `/home/lvu/repos/PAVICS-e2e-workflow-tests` is where you have this repo checked out on your local machine.

To stop the notebook:
```shell
docker stop birdy-notebook  # the container created by launchnotebook
```

## Build the docker image locally for testing a new version

```shell
cd docker
docker build -t my_image_name .
```

## Start Jupyter Notebook to test a local docker image build

```shell
DOCKER_IMAGE="my_image_name" ./launchnotebook [port]

# to volume mount more local dir into the container for testing new notebooks
DOCKER_IMAGE="my_image_name" DOCKER_RUN_OPTS="-v /some/dir/locally:/some/dir/in/container ./launchnotebook [port]
```

For usage, follow the same instructions as 'Start Jupyter notebook to modify one of the notebooks' above.

## Releasing a new Docker image

Use the script [`releasedocker`](releasedocker)` <old_ver> <new_ver>`, example:
`releasedocker 190311 190312`.

This script will commit, tag and push a new release. You will need write-access to the repo when using this script.

Then Docker Hub will build automatically the new tag, and eventually we will have a new image, example: [`pavics/workflow-tests:190312`](https://hub.docker.com/r/pavics/workflow-tests/tags).
