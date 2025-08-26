Beginner-Friendly DevOps Cloud Lab (By Vishal)
1. 📂 Project Folder Structure & Naming Conventions

Create a root folder called devops-lab-vishal:

devops-lab-vishal/
│── terraform/               # Terraform scripts for AWS infra
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│── ansible/                 # Ansible playbooks
│   ├── inventory.ini
│   ├── playbook.yml
│   ├── roles/
│       ├── jenkins/
│       ├── tomcat/
│── jenkins/                 # Jenkins pipeline related files
│   ├── Jenkinsfile
│── springboot-app/          # Your cloned GitHub app
│── README.md                # Documentation (write what you did)


👉 This helps keep things organized and reusable.

2. 🛠️ Install & Configure Tools (Local System: Windows Git Bash or Ubuntu)
On Ubuntu (recommended for fewer issues):
# Update system
sudo apt update && sudo apt upgrade -y

# Install Git
sudo apt install git -y

# Install AWS CLI
sudo apt install awscli -y

# Install Terraform
sudo apt install wget unzip -y
wget https://releases.hashicorp.com/terraform/1.9.5/terraform_1.9.5_linux_amd64.zip
unzip terraform_1.9.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform -v

# Install Ansible
sudo apt install ansible -y

# Install Java (needed for Jenkins, Maven, Spring Boot)
sudo apt install openjdk-17-jdk -y
java -version

# Install Maven
sudo apt install maven -y
mvn -v

# Install Docker (optional but useful)
sudo apt install docker.io -y

# Jenkins (later via Ansible or manual)

On Windows (Git Bash)

Install via chocolatey
 or WSL Ubuntu. I suggest WSL (Ubuntu inside Windows).

3. 🌩️ Use Terraform to Provision AWS Infrastructure
terraform/main.tf

Example for 1 Jenkins Master + 1 App Node:

provider "aws" {
  region = "ap-south-1"   # Change to your AWS region
}

resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "devops_subnet" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "devops_sg" {
  vpc_id = aws_vpc.devops_vpc.id

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
    cidr_blocks = ["0.0.0.0/0"] # Jenkins
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Tomcat
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins_master" {
  ami           = "ami-08e5424edfe926b43" # Ubuntu 22.04 in ap-south-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.devops_subnet.id
  key_name      = "vishal-key"
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  tags = {
    Name = "jenkins-master"
  }
}

resource "aws_instance" "app_node" {
  ami           = "ami-08e5424edfe926b43"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.devops_subnet.id
  key_name      = "vishal-key"
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  tags = {
    Name = "app-node"
  }
}


👉 Run:

cd terraform
terraform init
terraform plan
terraform apply -auto-approve

4. 🔑 SSH Access to EC2

When Terraform creates instances:

chmod 400 vishal-key.pem
ssh -i vishal-key.pem ubuntu@<public-ip>


Common error: "UNPROTECTED PRIVATE KEY FILE" → Fix with chmod 400.

5. ⚙️ Ansible Setup
ansible/inventory.ini
[jenkins]
<jenkins-public-ip> ansible_user=ubuntu ansible_ssh_private_key_file=../vishal-key.pem

[app]
<app-public-ip> ansible_user=ubuntu ansible_ssh_private_key_file=../vishal-key.pem

Example Playbook to install Jenkins (ansible/playbook.yml)
- hosts: jenkins
  become: yes
  tasks:
    - name: Install Java
      apt:
        name: openjdk-17-jdk
        state: present
        update_cache: yes

    - name: Add Jenkins repo key
      apt_key:
        url: https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
        state: present

    - name: Add Jenkins repo
      apt_repository:
        repo: "deb https://pkg.jenkins.io/debian-stable binary/"
        state: present

    - name: Install Jenkins
      apt:
        name: jenkins
        state: present
        update_cache: yes

    - name: Start Jenkins
      service:
        name: jenkins
        state: started
        enabled: yes


Run:

cd ansible
ansible-playbook -i inventory.ini playbook.yml

6. 📦 Jenkins Pipeline
jenkins/Jenkinsfile
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/<your-username>/<your-repo>.git'
            }
        }
        stage('Build with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Deploy with Ansible') {
            steps {
                ansiblePlaybook(
                    playbook: 'ansible/deploy.yml',
                    inventory: 'ansible/inventory.ini'
                )
            }
        }
    }
}

7. ⚡ Ansible Deploy Playbook (ansible/deploy.yml)
- hosts: app
  become: yes
  tasks:
    - name: Install Tomcat 9
      apt:
        name: tomcat9
        state: present
        update_cache: yes

    - name: Copy WAR to Tomcat
      copy:
        src: ../springboot-app/target/springboot-0.0.1-SNAPSHOT.war
        dest: /var/lib/tomcat9/webapps/app.war

8. 🌐 GitHub Webhook

In Jenkins: create Multibranch Pipeline or Freestyle with Git SCM.

In GitHub repo → Settings → Webhooks → Add:

http://<jenkins-public-ip>:8080/github-webhook/


Set trigger to GitHub hook trigger for GITScm polling.

9. 🖥️ Run App in Browser

Jenkins UI → http://<jenkins-ip>:8080

App URL → http://<app-ip>:8081/app
