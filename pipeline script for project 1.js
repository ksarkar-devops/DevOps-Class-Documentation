pipeline {
    agent any

    stages {
        stage('Clone repo') {
            steps {
                echo 'Clone GitHub Repository'
				git branch: 'main', url:"https://github.com/ksarkar-devops/spring-boot-hello-world.git"
            }
        }
		stage('List files') {
            steps {
                echo 'List all files in Jenkins Workspace folder'
				sh 'cd /var/lib/jenkins/workspace/DeployJavaProject/'
				sh 'ls -l'
            }
        }
        stage('Build') {
            steps {
                echo 'Build'
				sh 'mvn clean package'
            }
        }
		stage('Docker build') {
            steps {
                echo 'Docker build'
                sh 'cd /var/lib/jenkins/workspace/DeployJavaProject/'
                sh 'docker build -t java_proj .'
            }
        }
		stage('ACR Push') {
            steps {
                echo 'ACR Push'
				sh 'docker login ksarkar23987.azurecr.io --username ksarkar23987 --password xdS3VjuttNRMo8HA/Dg7jLY1/FexB8l+SMmiuWZouf+ACRDHTC/y'
                sh 'docker tag java_proj ksarkar23987.azurecr.io/test-repo:test-tag'
                sh 'docker push ksarkar23987.azurecr.io/test-repo:test-tag'
            }
        }
    }
}
