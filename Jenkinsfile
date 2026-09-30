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
                checkout scm
            }
        }

        stage('Terraform Action') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    
                    script {
                        if (params.ACTION == 'apply') {
                            echo 'Applying Terraform infrastructure...'
                            sh 'terraform apply -auto-approve -var="public_key_content=$(cat ~/.ssh/jenkins-agent.pub)"'
                        } else if (params.ACTION == 'destroy') {
                            echo 'Destroying Terraform infrastructure...'
                            sh 'terraform destroy -auto-approve -var="public_key_content=$(cat ~/.ssh/jenkins-agent.pub)"'
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
                dir('ansible') {
                    echo 'Running Ansible playbook...'
                    sh 'ansible-playbook -i inventory.ini playbook.yml'
                }
            }
        }
    }
}