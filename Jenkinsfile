pipeline{
    agent any
    tools{
        jdk 'Java17'
        maven 'Maven3'
    }
    environment {
        APP_NAME = 'e2e-devops-jenkins'
        RELEASE = '1.0.0'
        DOCKER_USER = 'saknouche'
        DOCKER_PASS = 'dockerhub'
        IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
        JENKINS_API_TOKEN = credentials('JENKINS_API_TOKEN')
    }
    stages{
        stage("Cleanup workspace"){
            steps{
                cleanWs()
            }
        }
        stage("Checkout from SCM"){
            steps{
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/soufiane-devops-projects/e2e-devops-jenkins'
            }
        }
        stage("Build application"){
            steps{
                sh 'mvn clean package'
            }
        }
        stage("Test application"){
            steps{
                sh 'mvn test'
            }
        }

        stage("Sonarqube Analysis"){
            steps{
                withSonarQubeEnv(installationName: 'sonarqube-scanner',credentialsId: 'jenkins-sonarqube-token') {
                    sh 'mvn sonar:sonar'    
                }
            }
        }

        stage("Quality Gate"){
            steps{
                waitForQualityGate(abortPipeline: false, credentialsId: 'jenkins-sonarqube-token')
            }
        }

        stage("Build & Push Docker Image"){
            steps{
                script {
                    docker.withRegistry('', DOCKER_PASS){
                        docker_image = docker.build("${IMAGE_NAME}")
                    }
                    docker.withRegistry('', DOCKER_PASS){
                        docker_image.push("${IMAGE_TAG}")
                        docker_image.push("latest")
                    }
                }
            }
        }

          stage("Trivy Scan") {
            steps {
                script {
                    sh ("docker run -v /srv/db:/root/.cache/ bitnami/trivy image --download-db-only")
		            sh ("docker run -v /var/run/docker.sock:/var/run/docker.sock bitnami/trivy image ${IMAGE_NAME}:${IMAGE_TAG} --no-progress --scanners vuln  --exit-code 0 --severity HIGH,CRITICAL --format table")

                }
            }

        }

        stage ('Cleanup Artifacts') {
            steps {
                script {
                    sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker rmi ${IMAGE_NAME}:latest"
                }
            }
        }

        stage("Trigger CD"){
            steps{
                script {
                     sh "curl -v -k --user admin:${JENKINS_API_TOKEN} -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' 'http://172.16.96.212:8080/job/gitops-complete-pipeline/buildWithParameters?token=gitops-token'"
                }
            }
        }
    }

    post {
            failure {
                emailext body: '''${SCRIPT, template="groovy-html.template"}''', 
                        subject: "${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - Failed", 
                        mimeType: 'text/html',to: "developpeur.web90@gmail.com"
                }
            success {
                emailext body: '''${SCRIPT, template="groovy-html.template"}''', 
                        subject: "${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - Successful", 
                        mimeType: 'text/html',to: "developpeur.web90@gmail.com"
            }      
    
        }

}