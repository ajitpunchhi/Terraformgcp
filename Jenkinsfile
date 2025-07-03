pipeline {
    agent any
    
    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-key')

    }
	
    stages {
        stage('Git Checkout') {
            steps {
               git "https://github.com/ajitpunchhi/Terraformgcp.git", branch: 'main'
            }
        }
        
        stage('Terraform Init') {
            steps {
                script {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                script {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

	    stage('Manual Approval') {
            steps {
                input "Approve?"
            }
        }
	    
        stage('Terraform Apply') {
            steps {
                script {
                    sh 'terraform apply tfplan'
                }
            }
        }
    }
}