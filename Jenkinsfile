#!groovy

pipeline {
    agent none

    stages {
        stage('container') {
            agent {
                dockerfile {
                    args '-v ${HOME}/bin:${HOME}/bin'
                    additionalBuildArgs '--build-arg BUILDER_UID=$(id -u)'
                }
            }
            stages {
                stage('clean') {
                    steps {
                        sh 'git reset --hard'
                        sh 'git clean -xffd'
                    }
                }
                stage('set_version') {
                    when { not { branch "master" } }
                    steps {
                        sh './bumpversion.sh build'
                    }
                }
                stage('release') {
                    when { branch 'master' }
                    steps {
                        withCredentials([usernamePassword(credentialsId: env.GIT_CREDENTIALS_ID, passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                            sh './bumpversion.sh release'
                        }
                    }
                }
                stage('package') {
                    steps {
                        sh 'mkdir -p target'
                        sh 'find . -maxdepth 1 -type d  ! -path . ! -path "*/\\.*" ! -path ./target | sort | while read plugin; do echo $plugin; zip -r -q - $plugin >"target/${plugin}.zip"; done'
                    }
                }
            }
            post {
                success {
                    dir('target/') {
                        archiveArtifacts artifacts: '*.zip', fingerprint: true, onlyIfSuccessful: true
                    }
                }
            }
        }
    }
}
