pipeline {
    agent any
    
    environment {
        // Define environment variables
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-key')
        TF_VAR_project_id = 'my-terraform-456814'
        TF_VAR_region = 'us-central1'
        TF_VAR_zone = 'us-central1-a'
        TF_VAR_environment = "${env.BRANCH_NAME == 'main'}"
        TF_IN_AUTOMATION = 'true'
        TF_INPUT = 'false'
    }
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select the Terraform action to perform'
        )
        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Auto approve the terraform apply/destroy (use with caution)'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Checking out code from ${env.BRANCH_NAME} branch"
                }
                checkout scm
            }
        }
        
        
        stage('Terraform Init') {
            steps {
                script {
                    echo "Initializing Terraform..."
                    sh '''
                        terraform init -backend-config="bucket=ajitgcpterraform" \
                                      -backend-config="prefix=terraform/state/${TF_VAR_environment}" \
                                      -upgrade
                    '''
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                script {
                    echo "Validating Terraform configuration..."
                    sh 'terraform validate'
                }
            }
        }
        
        stage('Terraform Format Check') {
            steps {
                script {
                    echo "Checking Terraform formatting..."
                    sh '''
                        if ! terraform fmt -check=true -diff=true; then
                            echo "Terraform files are not properly formatted"
                            echo "Run 'terraform fmt' to fix formatting issues"
                            exit 1
                        fi
                    '''
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                script {
                    echo "Creating Terraform execution plan..."
                    sh '''
                        terraform plan -detailed-exitcode \
                                      -var="environment=${TF_VAR_environment}" \
                                      -out=tfplan
                    '''
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    if (params.AUTO_APPROVE || env.BRANCH_NAME == 'main') {
                        echo "Auto-applying Terraform changes..."
                        sh 'terraform apply -auto-approve tfplan'
                    } else {
                        echo "Manual approval required for Terraform apply"
                        input message: 'Do you want to apply the Terraform plan?', ok: 'Apply'
                        sh 'terraform apply tfplan'
                    }
                }
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    echo "WARNING: This will destroy all resources!"
                    
                    if (params.AUTO_APPROVE) {
                        echo "Auto-destroying Terraform resources..."
                        sh 'terraform destroy -auto-approve'
                    } else {
                        input message: 'Are you sure you want to destroy all resources?', ok: 'Destroy'
                        sh 'terraform destroy'
                    }
                }
            }
        }
        
        stage('Terraform Output') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "Displaying Terraform outputs..."
                    sh '''
                        terraform output -json > terraform_outputs.json
                        cat terraform_outputs.json
                    '''
                    
                    // Archive the outputs
                    archiveArtifacts artifacts: 'terraform_outputs.json', fingerprint: true
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "Cleaning up workspace..."
                
                // Archive Terraform plan file
                if (fileExists('tfplan')) {
                    archiveArtifacts artifacts: 'tfplan', fingerprint: true
                }
                
                // Archive state file for backup (optional)
                if (fileExists('terraform.tfstate')) {
                    archiveArtifacts artifacts: 'terraform.tfstate', fingerprint: true
                }
            }
        }
        
        success {
            script {
                echo "Pipeline completed successfully!"
                
                // Send notification (configure as needed)
                // emailext (
                //     subject: "Terraform Pipeline Success - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                //     body: "The Terraform pipeline has completed successfully.\n\nEnvironment: ${env.TF_VAR_environment}\nAction: ${params.ACTION}\nBranch: ${env.BRANCH_NAME}",
                //     to: "${env.CHANGE_AUTHOR_EMAIL}"
                // )
            }
        }
        
        failure {
            script {
                echo "Pipeline failed! Check the logs for details."
                
                // Send failure notification
                // emailext (
                //     subject: "Terraform Pipeline Failed - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                //     body: "The Terraform pipeline has failed.\n\nEnvironment: ${env.TF_VAR_environment}\nAction: ${params.ACTION}\nBranch: ${env.BRANCH_NAME}\n\nCheck the build logs for more details.",
                //     to: "${env.CHANGE_AUTHOR_EMAIL}"
                // )
            }
        }
        
        cleanup {
            script {
                echo "Performing cleanup..."
                
                // Clean up sensitive files
                sh '''
                    rm -f tfplan
                    rm -f terraform_outputs.json
                '''
            }
        }
    }
}