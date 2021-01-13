provider "aws" {
    region = "us-east-2"

}


//aws launch configuration

resource "aws_launch_configuration" "awslaunch" {
  name = "aws-launch"
  image_id = "ami-0a0ad6b70e61be944"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.awsfw.id]
  associate_public_ip_address = true
  key_name = "TestEKS"
  user_data = <<-EOF
   #!/bin/bash
   sudo yum -y update
   sudo yum install -y httpd
   sudo service httpd start
   echo '<!doctype html><html><head><title>CONGRATULATIONS!!..You are on your way to become a Terraform expert!</title><style>body {background-color: #1c87c9;}</style></head><body></body></html>' | sudo tee /var/www/html/index.html
   echo "<BR><BR>Terraform autoscaled app multi-cloud lab<BR><BR>" >> /var/www/html/index.html
   echo "Hello World from $(hostname -f)" > /var/www/html/index.html
   EOF
}

// ec2 firewall

resource "aws_security_group" "awsfw" {
  name = "aws-fw"
  vpc_id = aws_vpc.tfvpc.id

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

resource "aws_autoscaling_group" "tfasg" {
   name = "tf-asg"
   max_size = 4
   min_size = 2
   launch_configuration = aws_launch_configuration.awslaunch.name
   vpc_zone_identifier = [aws_subnet.web1.id,aws_subnet.web2.id]
   target_group_arns = [aws_lb_target_group.pool.arn]

   tag {
      key = "Name"
      propagate_at_launch = true
      value = "tf-ec2VM"
   }
}

//ALB Load Balancer Configuration

resource "aws_lb" "alb" {
  name = "tf-alb"
  load_balancer_type = "application"
  subnets = [aws_subnet.web1.id,aws_subnet.web2.id]
  security_groups    = [aws_security_group.awsfw.id]
}


resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.pool.arn
  }
}

resource "aws_lb_target_group" "pool" {
  name = "web"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.tfvpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "Static" {
  listener_arn = aws_lb_listener.frontend.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pool.arn
  }
}

// networking config

resource "aws_vpc" "tfvpc" {
  cidr_block = "172.20.0.0/16"

  tags = {
    name = "tf-vpc"
  }
}

resource "aws_subnet" "web1" {
  cidr_block = "172.20.10.0/24"
  vpc_id = aws_vpc.tfvpc.id
  availability_zone = "us-east-2a"

  tags = {
    name = "sub-web1"
  }
}

resource "aws_subnet" "web2" {
  cidr_block = "172.20.20.0/24"
  vpc_id = aws_vpc.tfvpc.id
  availability_zone = "us-east-2b"

  tags = {
    name = "sub-web2"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tfvpc.id

  tags = {
    name = "igw"
  }
}

resource "aws_route" "tfroute" {
   route_table_id = aws_vpc.tfvpc.main_route_table_id
   destination_cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
}
