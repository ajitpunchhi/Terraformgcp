pipeline {
    agent any
    
    environment {
        // GCP Service Account credentials stored in Jenkins
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-key')
        
        // GCP Project Configuration
        GCP_PROJECT_ID = 'my-terraform-456814'
        GCP_REGION = 'us-central1'
        
        // Terraform Backend Configuration
        TF_STATE_BUCKET = 'ajitgcpterraform'
        TF_STATE_PREFIX = 'terraform/state'
        
        // Environment-specific settings
        ENVIRONMENT = "${env.BRANCH_NAME == 'main'}"
        TF_WORKSPACE = "${ENVIRONMENT}"
        
        // Terraform version
        TF_VERSION = '1.5.0'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "Checking out source code..."
                checkout scm
            }
        }
        
        stage('Setup Terraform') {
            steps {
                script {
                    sh '''
                        echo "Setting up Terraform ${TF_VERSION}..."
                        
                        # Check if Terraform is installed
                        if ! command -v terraform &> /dev/null; then
                            echo "Installing Terraform ${TF_VERSION}"
                            wget -q https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
                            unzip -q terraform_${TF_VERSION}_linux_amd64.zip
                            sudo mv terraform /usr/local/bin/
                            rm terraform_${TF_VERSION}_linux_amd64.zip
                        fi
                        
                        # Verify installation
                        terraform version
                        
                        # Authenticate with GCP
                        gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
                        gcloud config set project ${GCP_PROJECT_ID}
                    '''
                }
            }
        }
        
        stage('Verify Backend Storage') {
            steps {
                script {
                    sh '''
                        echo "Verifying GCS backend storage..."
                        
                        # Check if the state bucket exists
                        if ! gsutil ls gs://${TF_STATE_BUCKET} &> /dev/null; then
                            echo "Creating Terraform state bucket: ${TF_STATE_BUCKET}"
                            gsutil mb -p ${GCP_PROJECT_ID} -l ${GCP_REGION} gs://${TF_STATE_BUCKET}
                            
                            # Enable versioning for state file protection
                            gsutil versioning set on gs://${TF_STATE_BUCKET}
                            
                            # Set lifecycle policy to manage old versions
                            echo '{"lifecycle": {"rule": [{"action": {"type": "Delete"}, "condition": {"age": 90, "isLive": false}}]}}' > lifecycle.json
                            gsutil lifecycle set lifecycle.json gs://${TF_STATE_BUCKET}
                            rm lifecycle.json
                        else
                            echo "Terraform state bucket already exists: ${TF_STATE_BUCKET}"
                        fi
                        
                        # List bucket contents
                        echo "Current state files in bucket:"
                        gsutil ls gs://${TF_STATE_BUCKET}/${TF_STATE_PREFIX}/ || echo "No state files found (first run)"
                    '''
                }
            }
        }
        
        stage('Terraform Init') {
            steps {
                script {
                    sh '''
                        echo "Initializing Terraform with GCS backend..."
                        
                        # Initialize with backend configuration
                        terraform init \\
                            -backend-config="bucket=${TF_STATE_BUCKET}" \\
                            -backend-config="prefix=${TF_STATE_PREFIX}/${ENVIRONMENT}" \\
                            -backend-config="project=${GCP_PROJECT_ID}" \\
                            -backend-config="region=${GCP_REGION}" \\
                            -reconfigure
                        
                        # Select or create workspace
                        terraform workspace select ${TF_WORKSPACE} || terraform workspace new ${TF_WORKSPACE}
                        
                        echo "Current workspace: $(terraform workspace show)"
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
                        
                        # Format check
                        terraform fmt -check=true -diff=true
                    '''
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                script {
                    sh '''
                        echo "Creating Terraform execution plan..."
                        
                        # Create plan with environment-specific variables
                        terraform plan \\
                            -var="project_id=${GCP_PROJECT_ID}" \\
                            -var="region=${GCP_REGION}" \\
                            -var="environment=${ENVIRONMENT}" \\
                            -out=tfplan-${ENVIRONMENT}
                        
                        # Show plan summary
                        echo "Plan created for environment: ${ENVIRONMENT}"
                        terraform show -no-color tfplan-${ENVIRONMENT} > tfplan-${ENVIRONMENT}.txt
                    '''
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    sh '''
                        echo "Running security scan on Terraform plan..."
                        
                        # Optional: Use tfsec for security scanning
                        # if command -v tfsec &> /dev/null; then
                        #     tfsec . --format json --out tfsec-report.json
                        # fi
                        
                        # Basic validation
                        echo "Checking for sensitive data exposure..."
                        if grep -i "password\\|secret\\|key" *.tf; then
                            echo "WARNING: Potential sensitive data found in .tf files"
                        fi
                    '''
                }
            }
        }
        
        stage('Terraform Apply Approval') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                script {
                    // Show plan summary before approval
                    echo "Plan Summary for ${ENVIRONMENT} environment:"
                    sh "cat tfplan-${ENVIRONMENT}.txt"
                    
                    // Manual approval with plan details
                    input message: "Do you want to apply the Terraform plan for ${ENVIRONMENT} environment?", 
                          ok: 'Apply',
                          submitterParameter: 'SUBMITTER',
                          parameters: [
                              choice(name: 'CONFIRM', choices: ['No', 'Yes'], description: 'Confirm deployment')
                          ]
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                script {
                    sh '''
                        echo "Applying Terraform configuration for ${ENVIRONMENT} environment..."
                        echo "Submitter: ${SUBMITTER}"
                        
                        # Apply the plan
                        terraform apply -auto-approve tfplan-${ENVIRONMENT}
                        
                        # Show outputs
                        echo "Deployment completed. Outputs:"
                        terraform output
                    '''
                }
            }
        }
        
        stage('Backup State') {
            steps {
                script {
                    sh '''
                        echo "Creating backup of current state..."
                        
                        # Copy current state to backup location
                        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
                        gsutil cp gs://${TF_STATE_BUCKET}/${TF_STATE_PREFIX}/${ENVIRONMENT}/default.tfstate \\
                                  gs://${TF_STATE_BUCKET}/backups/${ENVIRONMENT}/terraform-${TIMESTAMP}.tfstate || true
                        
                        echo "State backup completed"
                    '''
                }
            }
        }
    }
    
    post {
        
        success {
            echo "✅ Terraform deployment completed successfully for ${ENVIRONMENT} environment!"
            
            script {
                sh '''
                    echo "Deployment Summary:"
                    echo "Environment: ${ENVIRONMENT}"
                    echo "GCP Project: ${GCP_PROJECT_ID}"
                    echo "Backend Bucket: ${TF_STATE_BUCKET}"
                    echo "State Path: ${TF_STATE_PREFIX}/${ENVIRONMENT}"
                    echo "Workspace: $(terraform workspace show)"
                '''
            }
        }
        
        failure {
            echo "❌ Terraform deployment failed for ${ENVIRONMENT} environment!"
            
            script {
                sh '''
                    echo "Failure occurred in ${ENVIRONMENT} environment"
                    echo "Check the logs above for details"
                    
                    # Show current state status
                    terraform state list || echo "Unable to list state"
                '''
            }
        }
        
    
    }
}
