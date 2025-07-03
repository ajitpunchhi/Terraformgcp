pipeline {
    agent any
    
    environment {
        // GCP Service Account credentials stored in Jenkins
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-key')
        
        // GCP Project ID
        GCP_PROJECT_ID = 'my-terraform-456814'
        
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Checkout source code from repository
                checkout scm
            }
        }
        
        stage('Terraform Init') {
            steps {
                script {
                    sh '''
                        echo "Initializing Terraform..."
                        terraform init -backend-config="bucket=your-terraform-state-bucket"
                    '''
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                script {
                    sh '''
                        echo "Validating Terraform configuration..."
                        terraform validate
                    '''
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                script {
                    sh '''
                        echo "Creating Terraform execution plan..."
                        terraform plan -out=tfplan -var="project_id=${GCP_PROJECT_ID}"
                    '''
                }
            }
        }
        
        stage('Terraform Apply Approval') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Manual approval for production deployments
                    input message: 'Do you want to apply the Terraform plan?', ok: 'Apply',
                          submitterParameter: 'SUBMITTER'
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh '''
                        echo "Applying Terraform configuration..."
                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }
        
        stage('Terraform Output') {
            steps {
                script {
                    sh '''
                        echo "Terraform outputs:"
                        terraform output
                    '''
                }
            }
        }
    }
    
    post {
              
        success {
            echo 'Terraform deployment completed successfully!'
            
            // Send notification on success (optional)
            // slackSend channel: '#deployments', 
            //          color: 'good', 
            //          message: "✅ Terraform deployment successful for ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
        }
        
        failure {
            echo 'Terraform deployment failed!'
            
            // Send notification on failure (optional)
            // slackSend channel: '#deployments', 
            //          color: 'danger', 
            //          message: "❌ Terraform deployment failed for ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
        }
        
    }
}