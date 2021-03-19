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
            image "pavics/workflow-tests:210216"
            label 'linux && docker'
        }
    }

    parameters {
        string(name: 'PAVICS_HOST', defaultValue: default_pavics_host,
               description: 'PAVICS host to run notebooks against.', trim: true)
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
        booleanParam(name: 'TEST_RAVEN_REPO', defaultValue: false,
                     description: 'Check the box to test raven repo.')
        string(name: 'RAVEN_BRANCH', defaultValue: 'master',
               description: 'RAVEN_REPO branch to test against.', trim: true)
        string(name: 'RAVEN_REPO', defaultValue: 'Ouranosinc/raven',
               description: 'https://github.com/Ouranosinc/raven repo or fork to test against.', trim: true)
        booleanParam(name: 'TEST_ESGF_COMPUTE_API_REPO', defaultValue: false,
                     description: 'Check the box to test esgf-compute-api repo.')
        string(name: 'ESGF_COMPUTE_API_BRANCH', defaultValue: 'devel',
               description: 'ESGF_COMPUTE_API_REPO branch to test against.', trim: true)
        string(name: 'ESGF_COMPUTE_API_REPO', defaultValue: 'ESGF/esgf-compute-api',
               description: 'https://github.com/ESGF/esgf-compute-api repo or fork to test against.', trim: true)
        booleanParam(name: 'VERIFY_SSL', defaultValue: true,
                     description: 'Check the box to verify SSL certificate for https connections to PAVICS host.')
        booleanParam(name: 'SAVE_RESULTING_NOTEBOOK', defaultValue: true,
                     description: '''Check the box to save the resulting notebooks of the run.
Note this is another run, will double the time and no guaranty to have same error as the run from py.test.''')
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
                                variable: 'COMPUTE_TOKEN')  // ESGF expect this env var name
                         ]) {
                        sh("VERIFY_SSL=${params.VERIFY_SSL} \
                            SAVE_RESULTING_NOTEBOOK=${params.SAVE_RESULTING_NOTEBOOK} \
                            ./testall")
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts(artifacts: 'notebooks/*.ipynb, pavics-sdi-*/docs/source/notebooks/*.ipynb, finch-*/docs/source/notebooks/*.ipynb, raven-*/docs/source/notebooks/*.ipynb, esgf-compute-api-*/examples/*.ipynb, buildout/*.output.ipynb, buildout/env-dump/',
                             fingerprint: true)
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
        timeout(time: 1, unit: 'HOURS')
        // trying to keep 2 months worth of history with buffer for manual
        // build trigger on failed builds or manual test after each production
        // deployment or test deployment
        buildDiscarder(logRotator(numToKeepStr: '200'))
    }
}
