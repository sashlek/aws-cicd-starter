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
                    
                    echo 'Applying Terraform infrastructure with Jenkins Secret Key...'
                    withCredentials([string(credentialsId: 'docker-vm-2', variable: 'SSH_PUB_KEY')]) {
                        sh 'terraform apply -auto-approve -var="public_key_content=${SSH_PUB_KEY}"'
                    }
                }
            }
        }

        stage('Ansible Configuration') {
            steps {
                script {
                    // Grab the dynamic IP directly from Terraform output
                    def ec2Ip = sh(script: 'cd terraform && terraform output -raw instance_public_ip', returnStdout: true).trim()
                    echo "Got dynamic EC2 IP: ${ec2Ip}"

                    dir('ansible') {
                        echo 'Running Ansible playbook against the new instance...'
                        // Pass the dynamic IP directly to Ansible, bypassing static inventory limitations
                        sh "ansible-playbook -i '${ec2Ip},' -u ubuntu --private-key ~/.ssh/id_ed25519 playbook.yml"
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
