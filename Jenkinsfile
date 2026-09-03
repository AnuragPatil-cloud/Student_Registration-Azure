pipeline {

    agent any

    options {
        timestamps()

        // Prevent two builds of this job from running at the same time
        disableConcurrentBuilds()

        // Keep recent build history under control
        buildDiscarder(
            logRotator(
                numToKeepStr: '20',
                artifactNumToKeepStr: '10'
            )
        )
    }

    environment {

        // Local image names
        BACKEND_IMAGE  = 'student-registration-backend'
        FRONTEND_IMAGE = 'student-registration-frontend'

        // Jenkins credential IDs
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'

        // Security gate
        TRIVY_SEVERITY = 'HIGH,CRITICAL'

        // Frontend API configuration
        VITE_API_URL = '/api'
    }

    stages {

        // =========================================================
        // CHECKOUT
        // =========================================================
        stage('Checkout') {
            steps {

                checkout scm

                sh '''
                    echo "=========================================="
                    echo "GIT CHECKOUT VERIFICATION"
                    echo "=========================================="

                    echo "Repository:"
                    git remote get-url origin

                    echo "Commit:"
                    git rev-parse HEAD

                    echo "Commit message:"
                    git log -1 --pretty=%B

                    echo "Branch environment:"
                    echo "${GIT_BRANCH}"

                    echo "GIT_COMMIT:"
                    echo "${GIT_COMMIT}"

                    echo "=========================================="
                '''
            }
        }

        // =========================================================
        // BACKEND TEST
        // =========================================================
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

        // =========================================================
        // FRONTEND LINT
        // =========================================================
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

        // =========================================================
        // IMAGE TAGGING
        // =========================================================
        stage('Prepare Image Tags') {
            steps {

                script {

                    env.GIT_SHA = sh(
                        script: 'git rev-parse --short=12 HEAD',
                        returnStdout: true
                    ).trim()

                    env.BUILD_TAG_VERSION =
                        "${env.GIT_SHA}-${env.BUILD_NUMBER}"

                    echo "Git SHA: ${env.GIT_SHA}"
                    echo "Image version: ${env.BUILD_TAG_VERSION}"
                }
            }
        }

        // =========================================================
        // BACKEND DOCKER BUILD
        // =========================================================
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

        // =========================================================
        // FRONTEND DOCKER BUILD
        // =========================================================
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

        // =========================================================
        // TRIVY BACKEND
        // =========================================================
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

        // =========================================================
        // TRIVY FRONTEND
        // =========================================================
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

        // =========================================================
        // DOCKER HUB PUSH
        // =========================================================
        stage('Docker Hub Push') {

            /*
             * Jenkins Pipeline jobs may checkout a commit in detached
             * HEAD mode. Therefore branch 'main' is not always reliable.
             *
             * This expression checks GIT_BRANCH instead.
             */
            when {
                expression {
                    return env.GIT_BRANCH == 'origin/main' ||
                           env.GIT_BRANCH == 'main'
                }
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

                            echo "=========================================="
                            echo "DOCKER HUB LOGIN"
                            echo "=========================================="

                            echo "$DOCKER_PASSWORD" | docker login \
                                --username "$DOCKER_USERNAME" \
                                --password-stdin

                            echo "Docker Hub user:"
                            echo "$DOCKER_USERNAME"

                            echo "=========================================="
                            echo "TAGGING BACKEND"
                            echo "=========================================="

                            docker tag \
                                ${BACKEND_IMAGE}:${BUILD_TAG_VERSION} \
                                ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${BUILD_TAG_VERSION}

                            docker tag \
                                ${BACKEND_IMAGE}:${GIT_SHA} \
                                ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${GIT_SHA}

                            echo "=========================================="
                            echo "TAGGING FRONTEND"
                            echo "=========================================="

                            docker tag \
                                ${FRONTEND_IMAGE}:${BUILD_TAG_VERSION} \
                                ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${BUILD_TAG_VERSION}

                            docker tag \
                                ${FRONTEND_IMAGE}:${GIT_SHA} \
                                ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${GIT_SHA}

                            echo "=========================================="
                            echo "PUSHING BACKEND"
                            echo "=========================================="

                            docker push \
                                ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${BUILD_TAG_VERSION}

                            docker push \
                                ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${GIT_SHA}

                            echo "=========================================="
                            echo "PUSHING FRONTEND"
                            echo "=========================================="

                            docker push \
                                ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${BUILD_TAG_VERSION}

                            docker push \
                                ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${GIT_SHA}

                            echo "=========================================="
                            echo "DOCKER HUB PUSH SUCCESSFUL"
                            echo "=========================================="

                            docker logout
                        '''
                    }
                }
            }
        }
                 stage('Update GitOps Image Tags') {
    when {
        expression {
            return env.GIT_BRANCH == 'origin/main' ||
                   env.GIT_BRANCH == 'main'
        }
    }
    steps {
        script {
            withCredentials([
                usernamePassword(
                    credentialsId: 'github-https',
                    usernameVariable: 'GITHUB_USERNAME',
                    passwordVariable: 'GITHUB_TOKEN'
                )
            ]) {
                sh '''
                    set -e

                    echo "=========================================="
                    echo "UPDATING GITOPS IMAGE TAGS"
                    echo "=========================================="

                    git config user.name "jenkins"
                    git config user.email "jenkins@localhost"

                    git fetch origin gitops
                    git checkout -B gitops origin/gitops

                    echo "Updating image tags to:"
                    echo "  Backend : ${BUILD_TAG_VERSION}"
                    echo "  Frontend: ${BUILD_TAG_VERSION}"

                    sed -i \
                        "s#^    tag: \".*\"#    tag: \"${BUILD_TAG_VERSION}\"#" \
                        helm/student-registration/values.yaml

                    echo "Updated values.yaml:"
                    grep -A5 -E '^backend:|^frontend:' \
                        helm/student-registration/values.yaml

                    git add helm/student-registration/values.yaml

                    if git diff --cached --quiet; then
                        echo "No GitOps image tag change detected."
                        exit 0
                    fi

                    git commit \
                        -m "Update application images to ${BUILD_TAG_VERSION}"

                    git push \
                        https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/AnuragPatil-cloud/Student_Registration-Azure-DevSecOps.git \
                        HEAD:gitops

                    echo "=========================================="
                    echo "GITOPS UPDATE SUCCESSFUL"
                    echo "=========================================="
                '''
            }
        }
    }
}             
        // =========================================================
        // IMAGE METADATA
        // =========================================================
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
                    echo "GIT INFORMATION"
                    echo "=========================================="

                    echo "GIT SHA: ${GIT_SHA}"
                    echo "BUILD: ${BUILD_NUMBER}"
                    echo "IMAGE VERSION: ${BUILD_TAG_VERSION}"
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

                archiveArtifacts(
                    artifacts: 'build-info.txt',
                    fingerprint: true
                )
            }
        }
    }

    // =============================================================
    // POST ACTIONS
    // =============================================================
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
Check the failed stage and console output.
==========================================
'''
        }

        always {

            sh '''
                echo "Cleaning Docker builder cache..."

                docker builder prune -f || true
            '''
        }
    }
}
