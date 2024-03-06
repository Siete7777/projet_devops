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

    user_data = <<-EOF
                #!/bin/bash
                sudo useradd --system --no-create-home --shell /bin/false prometheus
                wget https://github.com/prometheus/prometheus/releases/download/v2.47.1/prometheus-2.47.1.linux-amd64.tar.gz
                tar -xvf prometheus-2.47.1.linux-amd64.tar.gz
                cd prometheus-2.47.1.linux-amd64/
                sudo mkdir -p /data /etc/prometheus
                sudo mv prometheus promtool /usr/local/bin/
                sudo mv consoles/ console_libraries/ /etc/prometheus/
                sudo mv prometheus.yml /etc/prometheus/prometheus.yml
                sudo chown -R prometheus:prometheus /etc/prometheus/ /data/
                echo "
                [Unit]
                      Description=Prometheus
                      Wants=network-online.target
                      After=network-online.target

                      StartLimitIntervalSec=500
                      StartLimitBurst=5

                      [Service]
                      User=prometheus
                      Group=prometheus
                      Type=simple
                      Restart=on-failure
                      RestartSec=5s
                      ExecStart=/usr/local/bin/prometheus \
                        --config.file=/etc/prometheus/prometheus.yml \
                        --storage.tsdb.path=/data \
                        --web.console.templates=/etc/prometheus/consoles \
                        --web.console.libraries=/etc/prometheus/console_libraries \
                        --web.listen-address=0.0.0.0:9090 \
                        --web.enable-lifecycle

                      [Install]
                      WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/prometheus.service
                sudo systemctl enable prometheus
                sudo systemctl start prometheus

                sudo useradd --system --no-create-home --shell /bin/false node_exporter
                wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
                tar -xvf node_exporter-1.6.1.linux-amd64.tar.gz
                sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
                rm -rf node_exporter* 
                echo "[Unit]
                    Description=Node Exporter
                    Wants=network-online.target
                    After=network-online.target

                    StartLimitIntervalSec=500
                    StartLimitBurst=5

                    [Service]
                    User=node_exporter
                    Group=node_exporter
                    Type=simple
                    Restart=on-failure
                    RestartSec=5s
                    ExecStart=/usr/local/bin/node_exporter --collector.logind

                    [Install]
                    WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/node_exporter.service
                sudo systemctl enable node_exporter
                sudo systemctl start node_exporter
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