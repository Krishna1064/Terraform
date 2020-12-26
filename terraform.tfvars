user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y java-1.8*
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
  sudo yum install -y jenkins
  sudo service jenkins start
  sudo systemctl start jenkins.service
  sudo systemctl enable jenkins.service
  sudo yum install git -y
  sudo mkdir -p /opt/maven
  sudo wget https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz -O /opt/maven/apache-maven-3.6.3-bin.tar.gz
  sudo tar -xvzf /opt/maven/apache-maven-3.6.3-bin.tar.gz -C /opt/maven/
  sudo echo "export M2_HOME=/opt/maven/apache-maven-3.6.3" >>/home/ec2-user/.bash_profile
  sudo echo "export M2=/opt/maven/apache-maven-3.6.3/bin" >>/home/ec2-user/.bash_profile
  sudo echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.265.b01-1.amzn2.0.1.x86_64" >>/home/ec2-user/.bash_profile
  sudo echo "export PATH=\$PATH:\$JAVA_HOME:\$M2_HOME:\$M2:." >>/home/ec2-user/.bash_profile
  EOF

tomcat_user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y java-1.8*
  sudo wget https://downloads.apache.org/tomcat/tomcat-8/v8.5.60/bin/apache-tomcat-8.5.60.tar.gz -O /opt/apache-tomcat-8.5.60.tar.gz
  sudo tar -xvzf /opt/apache-tomcat-8.5.60.tar.gz -C /opt
  sudo chmod +x /opt/apache-tomcat-8.5.60/bin/startup.sh
  sudo mv /opt/apache-tomcat-8.5.60 /opt/tomcat
  sudo /opt/tomcat/bin/startup.sh
  sudo echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.265.b01-1.amzn2.0.1.x86_64" >>/home/ec2-user/.bash_profile
  sudo echo "export PATH=\$PATH:\$JAVA_HOME:." >>/home/ec2-user/.bash_profile
  EOF

docker_user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install docker -y
  sudo systemctl start docker.service
  sudo systemctl enable docker.service
  sudo docker pull tomcat:latest
  sudo docker pull tomcat:8.0
  sudo docker run --name tomcat-container -d -p 8080:8080 tomcat:8.0
  sudo useradd dockeradmin
  sudo usermod -aG docker dockeradmin
  sudo usermod -aG docker ec2-user
  sudo useradd ansadmin
  sudo usermod -aG docker ansadmin
  EOF

  ansible_user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install python -y
  sudo yum install python-pip -y
  sudo pip install ansible
  sudo yum install docker -y
  sudo systemctl start docker.service
  sudo systemctl enable docker.service
  sudo useradd ansadmin
  sudo usermod -aG docker ec2-user
  sudo usermod -aG docker ansadmin
  sudo mkdir -p /etc/ansible
  sudo mkdir -p /opt/docker
  sudo chown -R ansadmin:ansadmin /opt/docker
  sudo echo "ansadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  EOF