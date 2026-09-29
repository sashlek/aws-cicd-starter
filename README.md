# AWS DevOps Starter Project

A simple end-to-end DevOps starter project built to learn and demonstrate infrastructure provisioning, configuration management, and CI/CD pipelines using Terraform, Ansible, and Jenkins.

## What this project does

1. **Terraform** provisions an AWS EC2 instance (`t3.micro`) inside the default VPC, creates a Security Group allowing SSH (22) and HTTP (80), and registers your local SSH public key.
   
2. **Ansible** connects to the newly created EC2 instance, cleans up broken repos, installs Docker, and runs a test Nginx container to verify everything works.

3. **Jenkins** automates the whole process using a declarative `Jenkinsfile`.

---

## Project Structure

```text
aws-cicd-starter/
├── terraform/          # Infrastructure as Code (AWS VPC, EC2, SG)
├── ansible/            # Configuration Management (Docker installation playbook)
├── app/                # Placeholder for application code
└── Jenkinsfile         # Automated CI/CD Pipeline definition

Prerequisites:

AWS Account (Free Tier or active credits) & AWS CLI configured (aws configure)
Terraform installed locally
Ansible installed locally
A working SSH key pair (~/.ssh/id_ed25519.pub)


How to Run It Manually:

1. Provision Infrastructure (Terraform)

Navigate to the terraform folder, initialize, and apply:

cd terraform
terraform init
terraform plan
terraform apply

Note: Make sure to check/update your public key path in main.tf if it differs from the default.


2. Configure Server & Deploy App (Ansible)

After Terraform finishes, copy the output IP address and update ansible/inventory.ini. Then run the playbook:

cd ansible
ansible-playbook -i inventory.ini playbook.yml
Open your browser and visit http://&lt;YOUR_EC2_IP&gt; to see the Welcome to nginx! page.


3. Clean up

When you are done testing, destroy the infrastructure:

cd terraform
terraform destroy



Author:
Saša (Wannabe DevOps Engineer learning the hard way)

---

