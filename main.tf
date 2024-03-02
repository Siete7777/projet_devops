provider "aws" {
    region     = "us-east-1"
    access_key = ""
    secret_key = ""
}

resource "aws_instance" "OwnCloud" {
    ami           = "ami-0c7217cdde317cfec"
    instance_type = "t2.micro"

    tags = {
        Name = "OwnCloud"
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'
                sudo apt-get update
                sudo apt-get install -y docker-ce
                sudo systemctl enable docker
                sudo systemctl start docker
                sudo apt-get update
                sudo apt-get install docker-compose-plugin
                sudo apt-get install git
                EOF
}

resource "aws_instance" "Prometheus-Grafana" {
    ami = "ami-0c7217cdde317cfec"
    instance_type = "t2.micro"

    tags {
        Name = "Prometheus-Grafana"
    }
}


# Ouvrir les ports nécessaires dans le groupe de sécurité
resource "aws_security_group" "terraform_group" {
  name        = "terraform_group"
  description = "Security group for EC2 instance Terraform"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Jenkins
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SonarQube
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #OwnCloud
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}