####
#
# Data sources
#
####

data "aws_ami" "centos7" {
  most_recent = true
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["410186602215"] # Canonical
}


data "external" "example" {
  program = ["bash", "script.sh"]
  query = {
    # arbitrary map from strings to strings, passed
    # to the external program as the data query.
    id = "abc123"
  }
}


####
# Make an instance
####
 data "template_file" "run_time_user_data" {
   template = <<EOF
#!/bin/sh
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum -y install puppet-agent
sudo puppet --version

sudo yum update -y
#sudo yum install -y docker
sudo service docker enable
sudo service docker start
docker pull jenkins:latest
docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
docker run -d -p 8081:8081 --name nexus sonatype/nexus:oss

puppet agent --no-daemonize --onetime --verbose

EOF
 }

 resource "aws_instance" "centos7" {
   ami                    = "${data.aws_ami.centos7.id}"
   instance_type          = "t2.micro"
   key_name               = "liatrio-demo1"
   vpc_security_group_ids = ["${aws_security_group.liatrio-sg.id}"]
   subnet_id              = "subnet-31f32554"
   user_data              = "${data.template_file.run_time_user_data.rendered}"
   lifecycle {
     create_before_destroy = true
   }

   tags {
    team = "${var.tags["team"]}"
    application = "${var.tags["application"]}"
    provisioner = "${var.tags["provisioner"]}"
    environment = "${var.environment"]}"
    name        = "a-not-empty-name"
   }
 }

resource "aws_security_group" "liatrio-sg" {
  name          = "liatrio-sg"
  description   = "Allow traffic"
  vpc_id        = "vpc-2253a947"

#  # Allow everything everywhere to get to this box
#  ingress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow the rest of the world to get to port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow the rest of the world to get to port 8080-8085
  ingress {
    from_port   = 8080
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access to everywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


###
#
# outputs
#
###
output "ami" {
  value = "${data.aws_ami.centos7.id}"
}

output "instance" {
  value = "${data.aws_instance.centos7.id}"
}


output "url" {
  value = "${data.external.example}"
}
