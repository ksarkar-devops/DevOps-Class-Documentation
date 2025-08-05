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
        stage('Project Build') {
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
        stage('Docker Login') {
            steps {
                echo 'Docker Login'
				withCredentials([usernamePassword(credentialsId: 'acr-login', usernameVariable: 'ACR_USER', passwordVariable: 'ACR_PASS')]) {
                    sh '''
                        echo "$ACR_PASS" | docker login ksarkar23987.azurecr.io --username "$ACR_USER" --password-stdin
                    '''
                }
            }
        }
		stage('ACR Push') {
            steps {
                echo 'ACR Push'
                sh 'docker tag java_proj ksarkar23987.azurecr.io/test-repo:test-tag'
                sh 'docker push ksarkar23987.azurecr.io/test-repo:test-tag'
            }
        }
    }
}
