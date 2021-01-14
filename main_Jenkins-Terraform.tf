provider "aws" {
    region = "us-east-2"
}

resource "aws_instance" "k8scluster" {
  count = 2
  ami = "ami-0a91cd140a1fc148a"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["Jenkins-SG"]
  key_name = "TestEKS"
  iam_instance_profile = "EC2fullaccessRole"
  tags = {Name = "k8scluster-${count.index}"}
  user_data = <<-EOF
   #!/bin/bash
   sudo apt update
   sudo apt install openjdk-8-jdk-headless -y
   wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
   sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
   sudo apt-get update
   sudo apt-get install jenkins -y
   sudo systemctl start jenkins.service
   sudo systemctl enable jenkins.service
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install terraform
   sudo apt install git -y
   sudo apt install apache2-utils -y
   EOF
}

resource "local_file" "inventory" {
 filename = "./inventory/hosts.ini"
 content = <<EOF
[k8scluster]
${aws_instance.k8scluster[0].public_ip}
${aws_instance.k8scluster[1].public_ip}
EOF
}

/*
output "PublicIP" {
value = aws_instance.k8scluster.public_ip
#  value = "${formatlist("%v", aws_instance.cZServers.*.public_ip)}"
}
*/

