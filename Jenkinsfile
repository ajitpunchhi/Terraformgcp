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
        stage('Clone Repository') {
            steps {
                git 'https://github.com/ajitpunchhi/Terraformgcp.git'
                echo 'Repository cloned successfully.'
            }
        } 
}