variable "aws_image" {

    description = "amazon linux id for region us-east-1"
    default = "ami-04d29b6f966df1537"
    type = string
}

variable "awsinstance_type" {
    description = "aws instance type"
    default = "t2.micro"
    type = string
}

variable "user_data" {
     description = "user data for apache script"

 }

variable "tomcat_user_data" {
     description = "user data for apache script"

 }

variable "docker_user_data" {
     description = "user data for apache script"

 }

variable "ansible_user_data" {
     description = "user data for apache script"

 }
