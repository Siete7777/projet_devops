provider "aws"{
    region = "us-east-1"  # Remplacez par votre région AWS préférée
}

# Création de notre instance Owncloud  
resource "aws_instance""OwnCloud-DevOps"{
    ami           = "ami-0c7217cdde317cfec"  # ID de l'AMI Ubuntu 22.04 LTS
    instance_type = "t2.micro"               # Type d'instance
    key_name      = "AKIATCKAM6PFBKF47YKD "          # Remplacez par votre paire de clés SSH
                                               # Remplacez par l'ID de votre sous-réseau public
  
    tags = {
      Name = "ExampleInstance"
    }
}
# Test
# Test 2