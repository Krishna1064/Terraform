provider "aws" {
    region = "us-east-2"
}

resource "aws_instance" "ec2test" {
  ami = "ami-0a91cd140a1fc148a"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.Jenkins-SG.id]
  key_name = "TestEKS"
  iam_instance_profile = "EC2fullaccessRole"
  tags = {Name = "Jenkins-Server"}
  user_data = <<-EOF
   #!/bin/bash
   sudo apt update
   sudo apt install openjdk-11-jdk -y
   wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
   sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
   sudo apt-get update
   sudo apt-get install jenkins -y
   sudo systemctl status jenkins.service
   sudo systemctl start jenkins.service
   sudo systemctl enable jenkins.service
   sudo ufw allow 8080
   sudo ufw allow OpenSSH
   sudo ufw enable
   sudo ufw status
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install terraform
   sudo apt install git -y
   sudo apt install apache2-utils -y
   sudo apt update
   sudo apt upgrade -y
   sudo apt install ansible -y
   EOF

   provisioner "local-exec" {
    command = "echo ${aws_instance.ec2test.private_ip} >> private_ips.txt"
  }
}


// EC2 firewall

resource "aws_security_group" "Jenkins-SG" {

    name = "Jenkins-SG"

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 80
      protocol = "tcp"
      to_port = 80
    }

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 8080
      protocol = "tcp"
      to_port = 8080
    }

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 22
      protocol = "tcp"
      to_port = 22
    }

    egress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      protocol = "-1"
      to_port = 0
    }

}

output "PublicIP" {
value = aws_instance.ec2test.public_ip
#  value = "${formatlist("%v", aws_instance.cZServers.*.public_ip)}"
}
