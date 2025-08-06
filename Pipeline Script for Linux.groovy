pipeline {
    agent any

    stages {
        stage('Stage1') {
            steps {
                echo 'Clone GitHub Repository'
				git branch: 'main', url:"https://github.com/ksarkar-devops/classdevops.git"
            }
        }
		stage('Stage2') {
            steps {
                echo 'List all files in Jenkins Workspace folder'
				sh 'cd /var/lib/jenkins/workspace/proj1/'
				sh 'ls -l'
            }
        }
		stage('Stage3') {
            steps {
                echo 'Pipeline Successfully executed'
            }
        }
		stage('Stage4') {
            steps {
                echo 'Print todays calender'
				sh 'date'
            }
        }
    }
}
