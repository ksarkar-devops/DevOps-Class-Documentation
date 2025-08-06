pipeline {
    agent any

    stages {
        stage('Clone repo') {
            steps {
				git branch: 'main', url:"https://github.com/ksarkar-devops/spring-boot-hello-world.git"
            }
        }
		stage('List files') {
            steps {
				sh 'cd /var/lib/jenkins/workspace/DeployJavaProject/'
				sh 'ls -l'
            }
        }
        stage('Project Build') {
            steps {
                sh 'mvn clean package'
            }
        }
		stage('Docker build') {
            steps {
                sh 'cd /var/lib/jenkins/workspace/DeployJavaProject/'
				sh 'docker build -t java_proj .'
            }
        }
        stage('ACR Login') {
            steps {
				withCredentials([usernamePassword(credentialsId: 'acr-login', usernameVariable: 'ACR_USER', passwordVariable: 'ACR_PASS')]) {
                    sh 'echo "$ACR_PASS" | docker login ksarkar23987.azurecr.io --username "$ACR_USER" --password-stdin'
                }
            }
        }
		stage('ACR Push') {
            steps {
                sh 'docker tag java_proj ksarkar23987.azurecr.io/test-repo:test-tag'
				sh 'docker push ksarkar23987.azurecr.io/test-repo:test-tag'
            }
        }
    }
}
