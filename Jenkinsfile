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
        stage('Setup GCP Credentials') {
            steps {
                echo 'Setting up GCP credentials...'
                withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                        export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS
                        gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                        gcloud config set project ${PROJECT_ID}
                    '''
                }
            }
        }
        
        stage('Clone Repository') {
            steps {
                echo 'Cloning repository...'
                git url: 'https://github.com/ajitpunchhi/Terraformgcp.git', branch: 'main'
                // Ensure the repository is cloned to the workspace
            }

        stage('Initialize Terraform') {
            steps {
                echo 'Initializing Terraform...'
                sh '''
                    terraform init \
                        -backend-config="bucket=${bucket_name}" \
                        -backend-config="prefix=${state_file}" \
                        -backend-config="project=${PROJECT_ID}" \
                        -backend-config="region=${REGION}"
                '''
            }

        stage('Plan Terraform') {
            steps {
                echo 'Planning Terraform changes...'
                sh '''
                    terraform plan \
                        -var="project_id=${PROJECT_ID}" \
                        -var="region=${REGION}" \
                        -var="bucket_name=${bucket_name}"
                '''
            }
        stage('Apply Terraform') {
            steps {
                echo 'Applying Terraform changes...'
                sh '''
                    terraform apply -auto-approve \
                        -var="project_id=${PROJECT_ID}" \
                        -var="region=${REGION}" \
                        -var="bucket_name=${bucket_name}"
                '''
            }
        }

        stage('Copy State File to GCS') {
            steps {
                echo 'Copying Terraform state file to GCS...'
                sh '''
                    gsutil cp terraform.tfstate gs://${bucket_name}/${state_file}
                '''
            }
        }

}
    }
}
    }
}