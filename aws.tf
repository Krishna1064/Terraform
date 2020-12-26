//aws compute configuration

resource "aws_instance" "ec2test" {
  ami = var.aws_image
  instance_type = var.awsinstance_type
  vpc_security_group_ids = [aws_security_group.awsfw.id]
  key_name = "awspublickey"
  tags = {Name = "Jenkins-Server"}
  user_data = var.user_data
}

resource "aws_instance" "ec2tomcat" {
  ami = var.aws_image
  instance_type = var.awsinstance_type
  vpc_security_group_ids = [aws_security_group.awsfw.id]
  key_name = "awspublickey"
  tags = {Name = "Tomcat_server"}
  user_data = var.tomcat_user_data
}

resource "aws_instance" "ec2docker" {
  ami = var.aws_image
  instance_type = var.awsinstance_type
  vpc_security_group_ids = [aws_security_group.awsfw.id]
  key_name = "awspublickey"
  tags = {Name = "Docker-Server"}
  user_data = var.docker_user_data
}

resource "aws_instance" "ec2ansible" {
  ami = var.aws_image
  instance_type = var.awsinstance_type
  vpc_security_group_ids = [aws_security_group.awsfw.id]
  key_name = "awspublickey"
  tags = {Name = "Ansible_Server"}
  user_data = var.ansible_user_data
}


// EC2 firewall

resource "aws_security_group" "awsfw" {

    name = "aws-fw"

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

resource "aws_key_pair" "ssh" {

  key_name = "awspublickey"
  public_key = file("~/testec2.pub")

}
output "PublicIP" {
value = "aws_instance.ec2test.public_ip"
#  value = "${formatlist("%v", aws_instance.cZServers.*.public_ip)}"
}
