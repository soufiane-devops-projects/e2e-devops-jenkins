pipeline{
    agent any
    tools{
        jdk 'Java17'
        maven 'Maven3'
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
    }   
}