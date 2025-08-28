✅ Step 1: Clone the given repository

# 1) Choose a folder where you keep projects (example: Desktop)
cd ~/Desktop

# 2) Clone the repository
git clone https://github.com/akshu20791/addressbook-cicd-project.git

# 3) Go into the project
cd addressbook-cicd-project

# 4) Verify the remote URL
git remote -v

# List files to confirm
ls -l

# 5) (Optional but nice) open in VS Code if you have it
code .

In this step, I cloned the given GitHub repository addressbook-cicd-project to my local system using the git clone command. After moving inside the project folder, I listed the files with ls -l to verify that the project code (including pom.xml and src folder) has been successfully downloaded. This repository will later be pushed to my own GitHub account for CI/CD integration.

✅ Step 2: Create your own GitHub repository & push code
In this step, I created a new GitHub repository named vishalk-addressbook-cicd. This repository will host my cloned project code and act as the source for Jenkins integration. Keeping the repository public allows easier integration with CI/CD tools.

2.B STEP

# Make sure you are inside the cloned folder
cd ~/Desktop/addressbook-cicd-project

# Remove old origin
git remote remove origin

# Add your new GitHub repo URL (replace with your GitHub username)
git remote add origin https://github.com/<your-username>/vishalk-addressbook-cicd.git

# Push code to new repo
git push -u origin main


After creating the new repository, I linked my local cloned project to it using git remote add origin. Then I pushed the complete project code with git push -u origin main. Finally, I verified on GitHub that all project files are available in my repository. This step ensures Jenkins can pull the code directly from my own repository for further automation.



✅ Step 3: Terraform Script for AWS Infra

main.tf


# Provider Configuration wala
provider "aws" {
  region = "eu-north-1"   
}


# Security group for Jenkins + Application Node wala

resource "aws_security_group" "vishalk_sg" {
  name        = "vishalk-sg"
  description = "Allow SSH, Jenkins, and Tomcat access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]   # Allow all outbound
  }
}


# Jenkins Master Instance wala
resource "aws_instance" "vishalk_master" {
  ami             = "ami-0914547665e6a707c"   
  instance_type   = "t2.micro"
  key_name        = "vishal-key"              
  security_groups = [aws_security_group.vishalk_sg.name]

  tags = {
    Name = "vishalk_master"
  }
}


# Application Node Instance wala
resource "aws_instance" "vishalk_node" {
  ami             = "ami-0914547665e6a707c"  
  instance_type   = "t2.micro"
  key_name        = "vishal-key"             
  security_groups = [aws_security_group.vishalk_sg.name]

  tags = {
    Name = "vishalk_node"
  }
}


# Output IPs
output "jenkins_master_ip" {
  value = aws_instance.vishalk_master.public_ip
}

output "application_node_ip" {
  value = aws_instance.vishalk_node.public_ip
}


terraform init
terraform validate
terraform plan
terraform apply -auto-approve


I created a single Terraform file (main.tf) to provision my AWS infrastructure. The script launches two EC2 instances in the Stockholm region: vishalk_master (for Jenkins) and vishalk_node (for the Application Node). Both are connected to a common security group allowing SSH, Jenkins (8080), and Tomcat (9090) access. After running terraform init, terraform plan, and terraform apply, the two instances were successfully deployed, and I verified their public IPs from the Terraform output as well as the AWS Management Console.



provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Variables
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}


