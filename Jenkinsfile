pipeline {
    agent {
        label 'jenkins-agent'
    }

    environment {
        AWS_REGION = 'eu-central-1'
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
                    // We pass the Jenkins agent public SSH key dynamically to Terraform
                    sh 'terraform apply -auto-approve -var="public_key_content=$(cat ~/.ssh/jenkins-agent.pub)"'
                }
            }
        }

        stage('Ansible Configuration') {
            steps {
                dir('terraform') {
                    script {
                        // Extract the newly created EC2 instance public IP dynamically
                        def instanceIp = sh(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()
                        echo "Target EC2 Public IP is: ${instanceIp}"
                        
                        // Dynamically generate the Ansible inventory file with the correct IP and SSH key
                        dir('../ansible') {
                            writeFile file: 'inventory.ini', text: "[app_servers]\n${instanceIp} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/jenkins-agent\n"
                            echo "Generated dynamic inventory.ini successfully."
                        }
                    }
                }
                
                dir('ansible') {
                    echo 'Running Ansible playbook against the dynamic inventory...'
                    sh 'ansible-playbook -i inventory.ini playbook.yml'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully! Infrastructure is up, configured, and running.'
        }
        failure {
            echo 'Pipeline failed. Check the console logs above for details.'
        }
    }
}