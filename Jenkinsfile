String cron_only_on_master = ""
if (env.IS_PROD == "true" || env.ENABLE_SCHEDULED_TRIGGER == "true") {
    cron_only_on_master = env.BRANCH_NAME == "master" || env.GIT_BRANCH == 'origin/master' ? "@midnight" : ""
}

String default_pavics_host = env.DEFAULT_PAVICS_HOST != null ? env.DEFAULT_PAVICS_HOST : "pavics.ouranos.ca"

pipeline {
    // Guide book on Jenkins declarative pipelines
    // https://jenkins.io/doc/book/pipeline/syntax/
    agent {
        docker {
            image "pavics/workflow-tests:py311-241111"
            label 'linux && docker'
        }
    }

    parameters {
        string(name: 'CONFIG_PARAMETERS_SCRIPT_URL', defaultValue: '',
               description: 'Url to a script that will be sourced, allowing to programmatically set ALL Jenkins params on this page. Ex: https://raw.githubusercontent.com/Ouranosinc/PAVICS-e2e-workflow-tests/master/test-override/jenkins-params-raven-nb-only.include.sh', trim: true)
        string(name: 'PAVICS_HOST', defaultValue: default_pavics_host,
               description: 'PAVICS host to run notebooks against.', trim: true)
        // TEST_MAGPIE_AUTH enables the evaluation of end-2-end access to some secured Thredds and Geoserver resources
        // by Twitcher/Magpie and validates that resulting resources are found (or blocked) after proxy resolution of
        // granted/denied access.
        // If Authentication/Authorization is not needed or not employed for your instance, this should be disabled to
        // avoid failures.
        // NOTE:
        //   This test suite might require manual clean-up on failure (if critical error).
        //   The scripts attempt to remove everything, but could be incapable of doing so if Magpie become inaccessible
        //   midway during execution. Employed users/groups are not critical (not modifying existing users permissions),
        //   but could 'pollute' the user list over time.
        //   Also, a Geoserver workspace/layer with related Magpie resources are created specifically for the Geoserver
        //   test, but shouldn't impact existing resources. The test should normally clean the Geoserver workspace and
        //   related Magpie resources upon completion.
        booleanParam(name: 'TEST_MAGPIE_AUTH', defaultValue: false,
                     description: '''Check the box to test Authentication/Authorization using Magpie/Twitcher services.
This includes tests on Thredds and Geoserver resources.
Note: This test suite might require manual clean-up on failure (if critical error).
                     ''')
        // below credentials are the defaults from bootstrap script:
        //   https://github.com/bird-house/birdhouse-deploy/blob/master/birdhouse/scripts/create-magpie-authtest-user
        // overrides are needed when using custom values (strongly recommended for production server with real data)
        password(name: 'TEST_MAGPIE_ADMIN_USERNAME', defaultValue: 'admin',
                 description: 'Username of admin-level user to employ when running notebooks-auth tests.')
        password(name: 'TEST_MAGPIE_ADMIN_PASSWORD', defaultValue: 'qwertyqwerty!',
                  description: 'Password of admin-level user to employ when running notebooks-auth tests.')
        password(name: 'TEST_GEOSERVER_ADMIN_USERNAME', defaultValue: 'admin',
                 description: 'Username of admin-level Geoserver user to employ when running Geoserver tests.')
        password(name: 'TEST_GEOSERVER_ADMIN_PASSWORD', defaultValue: 'geoserverpass',
                  description: 'Password of admin-level Geoserver user to employ when running Geoserver tests.')
        booleanParam(name: 'TEST_PAVICS_SDI_REPO', defaultValue: true,
                     description: 'Check the box to test pavics-sdi repo.')
        string(name: 'PAVICS_SDI_BRANCH', defaultValue: 'master',
               description: 'PAVICS_SDI_REPO branch to test against.', trim: true)
        string(name: 'PAVICS_SDI_REPO', defaultValue: 'Ouranosinc/pavics-sdi',
               description: 'https://github.com/Ouranosinc/pavics-sdi repo or fork to test against.', trim: true)
        booleanParam(name: 'TEST_PAVICS_SDI_WEAVER', defaultValue: false,
                     description: '''Execute tests related to Weaver within PAVICS_SDI_REPO.
Requires 'weaver' component to be active on the target 'PAVICS_HOST' server
(see https://github.com/bird-house/birdhouse-deploy/tree/master/birdhouse/components#weaver).''')
        booleanParam(name: 'TEST_FINCH_REPO', defaultValue: true,
                     description: 'Check the box to test finch repo.')
        string(name: 'FINCH_BRANCH', defaultValue: 'master',
               description: 'FINCH_REPO branch to test against.', trim: true)
        string(name: 'FINCH_REPO', defaultValue: 'bird-house/finch',
               description: 'https://github.com/bird-house/finch repo or fork to test against.', trim: true)
        booleanParam(name: 'TEST_PAVICS_LANDING_REPO', defaultValue: true,
                     description: 'Check the box to test pavics-landing repo.')
        string(name: 'PAVICS_LANDING_BRANCH', defaultValue: 'master',
               description: 'PAVICS_LANDING_REPO branch to test against.', trim: true)
        string(name: 'PAVICS_LANDING_REPO', defaultValue: 'Ouranosinc/PAVICS-landing',
               description: 'https://github.com/Ouranosinc/PAVICS-landing repo or fork to test against.', trim: true)
        booleanParam(name: 'TEST_RAVEN_REPO', defaultValue: false,
                     description: 'Check the box to test raven repo.')
        string(name: 'RAVEN_BRANCH', defaultValue: 'main',
               description: 'RAVEN_REPO branch to test against.', trim: true)
        string(name: 'RAVEN_REPO', defaultValue: 'Ouranosinc/raven',
               description: 'https://github.com/Ouranosinc/raven repo or fork to test against.', trim: true)
        booleanParam(name: 'TEST_RAVENPY_REPO', defaultValue: false,
                     description: 'Check the box to test RavenPy repo.')
        string(name: 'RAVENPY_BRANCH', defaultValue: 'master',
               description: 'RAVENPY_REPO branch to test against.', trim: true)
        string(name: 'RAVENPY_REPO', defaultValue: 'CSHS-CWRA/RavenPy',
               description: 'https://github.com/CSHS-CWRA/RavenPy repo or fork to test against.', trim: true)
        booleanParam(name: 'TEST_ESGF_COMPUTE_API_REPO', defaultValue: false,
                     description: 'Check the box to test esgf-compute-api repo.  Kept here for historical reasons only, not working anymore.')
        string(name: 'ESGF_COMPUTE_API_BRANCH', defaultValue: 'devel',
               description: 'ESGF_COMPUTE_API_REPO branch to test against.', trim: true)
        string(name: 'ESGF_COMPUTE_API_REPO', defaultValue: 'ESGF/esgf-compute-api',
               description: 'https://github.com/ESGF/esgf-compute-api repo or fork to test against.', trim: true)
        string(name: 'PYTEST_EXTRA_OPTS', defaultValue: '--dist=loadscope --numprocesses=0',
               description: 'Extra options to pass to pytest, ex: --nbval-lax --dist=loadscope --numprocesses=0', trim: true)
        string(name: 'EXTRA_TEST_ENV_VAR', defaultValue: '',
               description: 'Extra environment variables for the various tests, ex: "TEST_RUNS=50 TEST_WPS_BIRDS=finch,raven,flyingpigeon TEST_NO_USE_PROD_DATA=1"', trim: true)
        string(name: 'CONFIG_OVERRIDE_SCRIPT_URL', defaultValue: '',
               description: 'Url or local file path to a script that will be sourced, allowing to programmatically override additional configs right before testsuite starts. Ex: https://raw.githubusercontent.com/Ouranosinc/PAVICS-e2e-workflow-tests/master/test-override/geoserver-nb-only.include.sh', trim: true)
        booleanParam(name: 'TEST_LOCAL_NOTEBOOKS', defaultValue: true,
                     description: 'Check the box to test notebooks in this repo (./notebooks/*.ipynb).')
        booleanParam(name: 'VERIFY_SSL', defaultValue: true,
                     description: 'Check the box to verify SSL certificate for https connections to PAVICS host.')
        booleanParam(name: 'SAVE_RESULTING_NOTEBOOK', defaultValue: true,
                     description: '''Check the box to save the resulting notebooks of the run.
Note this is another run, will double the time and no guaranty to have same error as the run from py.test.''')
        string(name: 'SAVE_RESULTING_NOTEBOOK_TIMEOUT', defaultValue: '240',
               description: 'Timeout in sec for nbconvert.  For slow notebooks or slow machine', trim: true)
    }

    triggers {
        cron(cron_only_on_master)
    }

    stages {
        stage('Run tests') {
            steps {
                script {
                    withCredentials(
                        [usernamePassword(credentialsId: 'esgf_auth',
                                          passwordVariable: 'ESGF_AUTH_PASSWORD',
                                          usernameVariable: 'ESGF_AUTH_USERNAME'),
                         string(credentialsId: 'esgf_auth_token',
                                variable: 'ESGF_AUTH_TOKEN'),  // Kept old env var name for backward compat
                         string(credentialsId: 'esgf_auth_token',
                                variable: 'COMPUTE_TOKEN'),  // ESGF expect this env var name
                         // For RavenPy HydroShare_integration.ipynb once a token is really required.
                         // Not enable immediately to not force all existing Jenkins deployments
                         // to add theses new credentials.
                         // See required Jenkins config change
                         // https://github.com/Ouranosinc/jenkins-config/commit/c6b36cfb761b5093375225a121ef5ec04684e84b
                         // https://github.com/Ouranosinc/jenkins-config/pull/15
                         // string(credentialsId: 'hydroshare_auth_client_id',
                         //        variable: 'HYDROSHARE_AUTH_CLIENT_ID'),
                         // string(credentialsId: 'hydroshare_auth_token',
                         //        variable: 'HYDROSHARE_AUTH_TOKEN'),
                         ]) {
                        sh("VERIFY_SSL=${params.VERIFY_SSL} \
                            SAVE_RESULTING_NOTEBOOK=${params.SAVE_RESULTING_NOTEBOOK} \
                            ${params.EXTRA_TEST_ENV_VAR} ./testall")
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts(artifacts: 'buildout/**/*.ipynb', fingerprint: true, allowEmptyArchive: true)
            archiveArtifacts(artifacts: 'buildout/env-dump/', fingerprint: true)
        }
	unsuccessful {  // Run if the current builds status is "Aborted", "Failure" or "Unstable"
            step([$class: 'Mailer', notifyEveryUnstableBuild: false,
                  recipients: emailextrecipients([
                        // enable once stable [$class: 'CulpritsRecipientProvider'],
                        // [$class: 'DevelopersRecipientProvider'],
                        [$class: 'RequesterRecipientProvider']])])
	}
    }

    options {
        ansiColor('xterm')
        timestamps()
        timeout(time: 2, unit: 'HOURS')
        // trying to keep 3 months worth of history
        // assuming manual build requests are done on a separated job
        buildDiscarder(logRotator(numToKeepStr: '100'))
    }
}
