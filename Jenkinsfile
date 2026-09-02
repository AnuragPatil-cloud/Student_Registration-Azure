pipeline {

    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(
            logRotator(
                numToKeepStr: '20',
                artifactNumToKeepStr: '10'
            )
        )
    }

    environment {
        BACKEND_IMAGE  = 'student-registration-backend'
        FRONTEND_IMAGE = 'student-registration-frontend'

        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'

        TRIVY_SEVERITY = 'HIGH,CRITICAL'

        VITE_API_URL = '/api'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm

                sh '''
                    echo "=========================================="
                    echo "Git Commit:"
                    git rev-parse HEAD
                    echo "=========================================="

                    echo "Branch:"
                    git branch --show-current || true

                    echo "Repository:"
                    git remote get-url origin
                '''
            }
        }

        stage('Backend Test') {
            steps {
                dir('backend') {
                    sh '''
                        echo "Running backend tests..."
                        mvn clean test
                    '''
                }
            }
        }

        stage('Frontend Lint') {
            steps {
                dir('frontend') {
                    sh '''
                        echo "Installing frontend dependencies..."
                        npm ci

                        echo "Running frontend lint..."
                        npm run lint
                    '''
                }
            }
        }

        stage('Prepare Image Tags') {
            steps {
                script {
                    env.GIT_SHA = sh(
                        script: 'git rev-parse --short=12 HEAD',
                        returnStdout: true
                    ).trim()

                    env.BUILD_TAG_VERSION = "${GIT_SHA}-${BUILD_NUMBER}"

                    echo "Git SHA: ${GIT_SHA}"
                    echo "Image version: ${BUILD_TAG_VERSION}"
                }
            }
        }

        stage('Build Backend Image') {
            steps {
                sh '''
                    echo "Building backend Docker image..."

                    docker build \
                        --pull \
                        -t ${BACKEND_IMAGE}:${BUILD_TAG_VERSION} \
                        -t ${BACKEND_IMAGE}:${GIT_SHA} \
                        ./backend
                '''
            }
        }

        stage('Build Frontend Image') {
            steps {
                sh '''
                    echo "Building frontend Docker image..."

                    docker build \
                        --pull \
                        --build-arg VITE_API_URL=${VITE_API_URL} \
                        -t ${FRONTEND_IMAGE}:${BUILD_TAG_VERSION} \
                        -t ${FRONTEND_IMAGE}:${GIT_SHA} \
                        ./frontend
                '''
            }
        }

        stage('Trivy Backend Scan') {
            steps {
                sh '''
                    echo "Scanning backend image..."

                    trivy image \
                        --scanners vuln,secret \
                        --severity ${TRIVY_SEVERITY} \
                        --exit-code 1 \
                        ${BACKEND_IMAGE}:${BUILD_TAG_VERSION}
                '''
            }
        }

        stage('Trivy Frontend Scan') {
            steps {
                sh '''
                    echo "Scanning frontend image..."

                    trivy image \
                        --scanners vuln,secret \
                        --severity ${TRIVY_SEVERITY} \
                        --exit-code 1 \
                        ${FRONTEND_IMAGE}:${BUILD_TAG_VERSION}
                '''
            }
        }

        stage('Docker Hub Push') {

            when {
                branch 'main'
            }

            steps {

                script {

                    withCredentials([
                        usernamePassword(
                            credentialsId: "${DOCKERHUB_CREDENTIALS}",
                            usernameVariable: 'DOCKER_USERNAME',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )
                    ]) {

                        sh '''
                            set -e

                            echo "Logging into Docker Hub..."

                            echo "$DOCKER_PASSWORD" | docker login \
                                --username "$DOCKER_USERNAME" \
                                --password-stdin

                            echo "Tagging backend image..."

                            docker tag \
                                ${BACKEND_IMAGE}:${BUILD_TAG_VERSION} \
                                ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${BUILD_TAG_VERSION}

                            docker tag \
                                ${BACKEND_IMAGE}:${GIT_SHA} \
                                ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${GIT_SHA}

                            echo "Tagging frontend image..."

                            docker tag \
                                ${FRONTEND_IMAGE}:${BUILD_TAG_VERSION} \
                                ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${BUILD_TAG_VERSION}

                            docker tag \
                                ${FRONTEND_IMAGE}:${GIT_SHA} \
                                ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${GIT_SHA}

                            echo "Pushing backend..."

                            docker push \
                                ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${BUILD_TAG_VERSION}

                            docker push \
                                ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${GIT_SHA}

                            echo "Pushing frontend..."

                            docker push \
                                ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${BUILD_TAG_VERSION}

                            docker push \
                                ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${GIT_SHA}

                            echo "Docker Hub push completed."

                            docker logout
                        '''
                    }
                }
            }
        }

        stage('Image Metadata') {
            steps {
                sh '''
                    echo "=========================================="
                    echo "BACKEND IMAGE"
                    echo "=========================================="

                    docker image inspect \
                        ${BACKEND_IMAGE}:${BUILD_TAG_VERSION} \
                        --format '{{.RepoTags}}'

                    echo "=========================================="
                    echo "FRONTEND IMAGE"
                    echo "=========================================="

                    docker image inspect \
                        ${FRONTEND_IMAGE}:${BUILD_TAG_VERSION} \
                        --format '{{.RepoTags}}'

                    echo "=========================================="
                    echo "GIT SHA"
                    echo "=========================================="

                    echo "${GIT_SHA}"
                '''

                writeFile(
                    file: 'build-info.txt',
                    text: """\
Application: Student Registration
Git Commit: ${env.GIT_SHA}
Build Number: ${env.BUILD_NUMBER}
Backend Image: ${env.BACKEND_IMAGE}:${env.BUILD_TAG_VERSION}
Frontend Image: ${env.FRONTEND_IMAGE}:${env.BUILD_TAG_VERSION}
""".stripIndent()
                )

                archiveArtifacts artifacts: 'build-info.txt',
                    fingerprint: true
            }
        }
    }

    post {

        success {
            echo '''
==========================================
 Jenkins Pipeline SUCCESS
==========================================
'''
        }

        failure {
            echo '''
==========================================
 Jenkins Pipeline FAILED
==========================================
Check the failed stage and fix the issue.
==========================================
'''
        }

        always {
            sh '''
                echo "Cleaning unused Docker build cache..."

                docker builder prune -f || true
            '''
        }
    }
}
