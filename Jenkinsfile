pipeline {
    agent any

    environment {
        PROJECT_ID = 'my-terraform-456814'  // Change this to your actual project ID
        REGION     = 'us-central1'          // Change this to your desired region
        bucket_name = 'ajitgcpterraform' // Change this to your actual bucket name
        state_file  = 'terraform.tfstate'   // Name of the Terraform state file
        service_account_key = credentials('gcp-service-account-key') // Jenkins credential ID for GCP service account key
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out code from repository...'
                git url: 'https://github.com/ajitpunchhi/Terraformgcp.git' branch: 'main'
                echo 'Code checked out successfully.'
            }
        }

        stage('Initialize Terraform') {
            steps {
                sh '''
                    terraform init \
                        -backend-config="bucket=${bucket_name}" \
                        -backend-config="prefix=terraform/state" \
                        -backend-config="project=${PROJECT_ID}" \
                        -backend-config="region=${REGION}" \
                        -backend-config="credentials=${service_account_key}"
                '''
                echo 'Terraform initialized successfully.'
            }
        }
        stage('Plan Terraform') {
            steps {
                sh 'terraform plan -out=tfplan'
                echo 'Terraform plan created successfully.'
            }
        }
        stage('Apply Terraform') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
                echo 'Terraform applied successfully.'
            }
        }
        stage('Copy State File') {
            steps {
                sh '''
                    gsutil cp ${state_file} gs://${bucket_name}/terraform/state/${state_file}
                '''
                echo 'Terraform state file copied to GCS bucket successfully.'
            }
        }
}
}