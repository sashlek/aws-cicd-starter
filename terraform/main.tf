# Use default VPC
data "aws_vpc" "default" {
  default = true
}

# Get a specific default subnet in the default VPC
data "aws_subnet" "default" {
  vpc_id = data.aws_vpc.default.id
  default_for_az = true
}

# Security Group allowing SSH and HTTP
resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-security-group"
  }
}

# Get the latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Optional: if you want to use an existing key pair, specify its name here
  key_name      = aws_key_pair.deployer.key_name

  associate_public_ip_address = true

  tags = {
    Name = "devops-starter-server"
  }
}

# Variable for the public key coming from Jenkins Credentials
variable "public_key_content" {
  type = string
}

# Register the public key in AWS
resource "aws_key_pair" "deployer" {
  key_name   = "devops-starter-key"
  public_key= var.public_key_content
}