pipeline {
    agent {
        label 'jenkins-agent'
    }

    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose whether to provision or destroy infrastructure')
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

        stage('Terraform Action') {
            steps {
                dir('terraform') {
                    echo 'Initializing Terraform...'
                    sh 'terraform init'
                    
                    script {
                        // Read public key into a variable to avoid dumping it loudly in logs
                        def pubKey = sh(script: 'cat ~/.ssh/jenkins-agent.pub', returnStdout: true).trim()
                        
                        if (params.ACTION == 'apply') {
                            echo 'Applying Terraform infrastructure...'
                            withEnv(["TF_VAR_public_key_content=${pubKey}"]) {
                                sh 'terraform apply -auto-approve'
                            }
                        } else if (params.ACTION == 'destroy') {
                            echo 'Destroying Terraform infrastructure...'
                            withEnv(["TF_VAR_public_key_content=${pubKey}"]) {
                                sh 'terraform destroy -auto-approve'
                            }
                        }
                    }
                }
            }
        }

        stage('Ansible Configuration') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir('terraform') {
                    script {
                        def instanceIp = sh(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()
                        echo "Target EC2 Public IP is: ${instanceIp}"
                        
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
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the console logs above for details.'
        }
    }
}