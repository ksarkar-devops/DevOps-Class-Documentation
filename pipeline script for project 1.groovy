pipeline {
    agent any
    
    environment {
	    IMAGE_NAME = 'java-app'
	    IMAGE_TAG = 'test-tag'
	    ACR_NAME = 'ksarkar23987'
	    ACR_REPO = 'test-repo'
	    CLUSTER_NAME = 'kube-cluster'
	    NAMESPACE = 'default'
	    ACR_LOADBALANCER = 'java-app-lb'
		PIPELINE_NAME = 'DeployJavaProject'
		AZURE_SUBSCRIPTION_ID = '719c1e53-b3fd-4af0-99f9-46469a324ca7'
		AZURE_RESOURCE_GROUP = 'rg'
	}

    stages {
        stage('Clone repo') {
            steps {
				git branch: 'main', url:"https://github.com/ksarkar-devops/spring-boot-hello-world.git"
            }
        }
		stage('List files') {
            steps {
				sh 'cd /var/lib/jenkins/workspace/${PIPELINE_NAME}/'
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
                sh 'cd /var/lib/jenkins/workspace/${PIPELINE_NAME}/'
				sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }
        stage('ACR Login') {
            steps {
				withCredentials([usernamePassword(credentialsId: 'acr-login', usernameVariable: 'ACR_USER', passwordVariable: 'ACR_PASS')]) {
                    sh 'echo "$ACR_PASS" | docker login ${ACR_NAME}.azurecr.io --username "$ACR_USER" --password-stdin'
                }
            }
        }
		stage('ACR Push') {
            steps {
                sh 'docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ACR_NAME}.azurecr.io/${ACR_REPO}:${IMAGE_TAG}'
				sh 'docker push ${ACR_NAME}.azurecr.io/${ACR_REPO}:${IMAGE_TAG}'
            }
        }
		stage('AKS Login') {
            steps {
                sh 'az login --identity'
                sh 'az account set --subscription ${AZURE_SUBSCRIPTION_ID}'
				sh 'az aks get-credentials --resource-group ${AZURE_RESOURCE_GROUP} --name ${CLUSTER_NAME} --overwrite-existing'
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
                        kubectl set image deployment/${IMAGE_NAME} ${ACR_REPO}=${ACR_NAME}.azurecr.io/${ACR_REPO}:${IMAGE_TAG} -n ${NAMESPACE}
                    else
                        echo "Creating new deployment..."
                        kubectl create deployment ${IMAGE_NAME} --image=${ACR_NAME}.azurecr.io/${ACR_REPO}:${IMAGE_TAG} -n ${NAMESPACE}
                    fi
                '''
                sh 'kubectl rollout status deployment/${IMAGE_NAME} -n ${NAMESPACE}'
            }
        }
		stage('Expose the app') {
            steps {
                sh '''
                    if kubectl get service ${ACR_LOADBALANCER} -n ${NAMESPACE} > /dev/null 2>&1; then
                        echo "Service already exists. Skipping expose."
                    else
                        kubectl expose deployment ${IMAGE_NAME} --type=LoadBalancer --name=${ACR_LOADBALANCER} -n ${NAMESPACE} --port=80 --target-port=8080
                    fi
                '''
				sh 'sleep 30'
                sh 'kubectl get svc ${ACR_LOADBALANCER} -n ${NAMESPACE}'
            }
        }
    }
}
