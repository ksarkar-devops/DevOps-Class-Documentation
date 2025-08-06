pipeline {
    agent any
    
    environment {
        IMAGE_NAME = 'test-repo'
        IMAGE_TAG = 'test-tag'
        CLUSTER_NAME = 'kube-cluster'
        NAMESPACE = 'default'
    }
    
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
				sh 'docker build -t javaproj .'
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
		stage('AKS Login') {
            steps {
                sh 'az login --identity'
                sh 'az account set --subscription 719c1e53-b3fd-4af0-99f9-46469a324ca7'
				sh 'az aks get-credentials --resource-group rg --name kube-cluster --overwrite-existing'
            }
        }
		stage('Confirm after AKS Login') {
            steps {
                sh 'kubectl config current-context'
				sh 'kubectl get nodes'
            }
        }
        stage('Deploy to AKS') {
            steps {
                sh '''
                    if kubectl get deployment ${IMAGE_NAME} -n ${NAMESPACE}; then
                        echo "Deployment exists. Updating image..."
                        kubectl set image deployment/${IMAGE_NAME} ${IMAGE_NAME}=${ACR_NAME}/${IMAGE_NAME}:${IMAGE_TAG} -n ${NAMESPACE}
                    else
                        echo "Creating new deployment..."
                        kubectl create deployment ${IMAGE_NAME} --image=${ACR_NAME}/${IMAGE_NAME}:${IMAGE_TAG} -n ${NAMESPACE}
                    fi
                '''
                sh 'kubectl rollout status deployment/${IMAGE_NAME} -n ${NAMESPACE}'
            }
        }
    }
}
