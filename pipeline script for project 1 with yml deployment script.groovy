pipeline {
    agent any
    
    environment {
	    IMAGE_NAME = 'java-app'
	    IMAGE_TAG = 'latest'
	    ACR_NAME = 'ksarkar23987'
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
		stage('Docker Push to ACR') {
            steps {
                sh 'docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}'
				sh 'docker push ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}'
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
                sh 'kubectl apply -f AKSDeployment.yml'
                sh 'kubectl rollout status deployment/${IMAGE_NAME} -n ${NAMESPACE}'
            }
        }
		stage('Expose the app') {
            steps {
				sh 'sleep 30'
                sh 'kubectl get svc ${ACR_LOADBALANCER} -n ${NAMESPACE}'
            }
        }
    }
}
