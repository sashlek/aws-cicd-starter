pipeline {
    agent {
        label 'jenkins-agent'
    }

    environment {
        AWS_REGION = 'eu-central-1'
        // Jenkins-Credentials-ID
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Fetching code from repository...'
                checkout scm
            }
        }

        stage('Terraform Provision') {
            steps {
                dir('terraform') {
                    echo 'Initializing Terraform...'
                    sh 'terraform init'
                    
                    echo 'Applying Terraform infrastructure...'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Ansible Configuration') {
            steps {
                dir('ansible') {
                    echo 'Running Ansible playbook to configure server and deploy container...'
                    sh 'ansible-playbook -i inventory.ini playbook.yml'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully! Infrastructure is up and configured.'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
