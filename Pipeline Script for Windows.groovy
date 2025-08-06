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
				bat 'dir /b C:\\ProgramData\\Jenkins\\.jenkins\\workspace\\pipeline-project'
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
				bat 'echo %date%'
            }
        }
    }
}
