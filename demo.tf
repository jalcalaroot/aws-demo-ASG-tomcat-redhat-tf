### ingresar credenciales
variable "access_key" {}
variable "secret_key" {}
variable "region" {}
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

#-----------------------------------------------------------
#VPC	
resource "aws_vpc" "jalcalaroot" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
     Name = "jalcalaroot"
     env = "terraform"
  }
}
#-----------------------------------------------------------
#.......................
###Subnets Publicas###
#.......................

#Public Subnet 0
resource "aws_subnet" "public-subnet-0" {
  vpc_id            = "${aws_vpc.jalcalaroot.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.128.0/20"
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-0"
    env       = "terraform"
    layer     = "public"
  }
}

#Public Subnet 1
resource "aws_subnet" "public-subnet-1" {
  vpc_id            = "${aws_vpc.jalcalaroot.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.144.0/20"
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-1"
    env       = "terraform"
    layer     = "public"
  }
}

#Public Subnet 2
resource "aws_subnet" "public-subnet-2" {
  vpc_id            = "${aws_vpc.jalcalaroot.id}"
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.160.0/20"	
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-2"
    env       = "terraform"
    layer     = "public"
  }
}

#------------------------------------------------------------
##########################################################
# Internet Gateway
# ..... Create and Route
##########################################################

resource "aws_internet_gateway" "jalcalaroot-igw" {
  vpc_id = "${aws_vpc.jalcalaroot.id}"

  tags = {
    Name      = "jalcalaroot-igw"
    env       = "terraform"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.jalcalaroot.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.jalcalaroot-igw.id}"
  }

  tags = {
    Name      = "public-rt"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "public-subnets-assoc-0" {
  subnet_id      = "${element(aws_subnet.public-subnet-0.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
resource "aws_route_table_association" "public-subnets-assoc-1" {
  subnet_id      = "${element(aws_subnet.public-subnet-1.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
resource "aws_route_table_association" "public-subnets-assoc-2" {
  subnet_id      = "${element(aws_subnet.public-subnet-2.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}


#--------------------------------------------------------------
#..................
#Private Subnets A = con salida a internet
#..................
 
#Public Subnet A0
resource "aws_subnet" "private-subnet-A0" {
  vpc_id            = "${aws_vpc.jalcalaroot.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.0.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-A0"
    env       = "terraform"
    layer     = "private"
  }
}

#Public Subnet A1
resource "aws_subnet" "private-subnet-A1" {
  vpc_id            = "${aws_vpc.jalcalaroot.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.32.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-A1"
    env       = "terraform"
    layer     = "private"
  }
}

#Public Subnet A2
resource "aws_subnet" "private-subnet-A2" {
  vpc_id            = "${aws_vpc.jalcalaroot.id}"
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.64.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-A2"
    env       = "terraform"
    layer     = "private"
  }
}
#--------------------------------------------------------------
/*##########################################################
# NAT Gateway
# ..... Create and Route
##########################################################*/

resource "aws_eip" "natgw-a" {
  vpc = true
}

resource "aws_nat_gateway" "natgw-a" {
  allocation_id = "${aws_eip.natgw-a.id}"
  subnet_id     = "${aws_subnet.public-subnet-0.id}"
}

resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.jalcalaroot.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw-a.id}"
  }

  tags = {
    Name      = "private-rt"
    env       = "terraform"
  }
}

resource "aws_route_table_association" "private-subnets-assoc-0" {
  subnet_id      = "${element(aws_subnet.private-subnet-A0.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "private-subnets-assoc-1" {
  subnet_id      = "${element(aws_subnet.private-subnet-A1.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt.id}"
}
resource "aws_route_table_association" "private-subnets-assoc-2" {
  subnet_id      = "${element(aws_subnet.private-subnet-A2.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

#---------------------------------------------------------
#..................
#Private Subnets B = sin salida a internet
#..................

#Private Subnet B0
resource "aws_subnet" "private-subnet-B0" {
  vpc_id            = "${aws_vpc.jalcalaroot.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.192.0/21"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-B0"
    env       = "terraform"
    layer     = "private"
  }
}

#Private Subnet B1
resource "aws_subnet" "private-subnet-B1" {
  vpc_id            = "${aws_vpc.jalcalaroot.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.200.0/21"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-B1"
    env       = "terraform"
    layer     = "private"
  }
}

#Private Subnet B2
resource "aws_subnet" "private-subnet-B2" {
  vpc_id            = "${aws_vpc.jalcalaroot.id}"
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.208.0/21"
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-B2"
    env       = "terraform"
    layer     = "private"
  }
}

#-----------------------------------------------------------
output "vpc_id" {
  value = "${aws_vpc.jalcalaroot.id}"
}

output "public-subnet-0" {
  value = "${aws_subnet.public-subnet-0.id}"
}
output "private-subnet-A0" {
  value = "${aws_subnet.private-subnet-A0.id}"
}
output "private-subnet-B0" {
  value = "${aws_subnet.private-subnet-B0.id}"
}
#------------------------------------------------------------
#SG
resource "aws_security_group" "ec2-sg" {
  name = "ec2-sg"
  description = "ec2-sg"
  vpc_id      = "${aws_vpc.jalcalaroot.id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
# SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
# HTTP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
# https
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
# tomcat
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
# KAS
  ingress {
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    name = "ec2-sg"
    env  = "terraform"
  }
}
#--------------------------------------------------------
resource "aws_key_pair" "jalcalaroot" {
  key_name = "jalcalaroot"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7f56ewMZz4WLRzKLy8mnJ2ZS1gWhDiE3A4UinEqlogZQCuibNRSsF8C9oXg6IlxdeqBet5Zx4jf/qgTuEDVCF7QyyYxFtNKctSX901spJXhpusx4k9aMPmsTHGCj7DL1mHKwrvb7fSdJcsffo8R/3NWzP7bBcwLgZeTw/vSYvECNnco7yvPhIiHSvTfggj8s4tVEMb8vqkvfDJm6gRTpw3+KsA2yZGuiSFNQQcpbckVwbP5iSbalmJkRBPV5PWVx1wYLkSuPY4b6wAYyggfJ50rRO5Pvs7xhyJ7cXxTflE1OalZNpSLkAErYn4uuiW6az4BMHTB2aTVt98JEeoIwF jalcalaroot@jalcalaroot-VIT-P2412"
}

#--------------------------------------------------------
## Creating Launch Configuration
resource "aws_launch_configuration" "jalcalaroot" {
name_prefix = "jalcalaroot"
  image_id               = "ami-9887c6e7"
  instance_type          = "t2.micro"
  security_groups        = ["${aws_security_group.ec2-sg.id}"]
  key_name               = "jalcalaroot"
  user_data              = "${file("deploy.sh")}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 30
  }
  lifecycle {
    create_before_destroy = true
  }
}
#---------------------------------------------------------
## Creating AutoScaling Group
resource "aws_autoscaling_group" "jalcalaroot" {
name =  "jalcalaroot"
  launch_configuration = "${aws_launch_configuration.jalcalaroot.id}"
  vpc_zone_identifier = ["${aws_subnet.public-subnet-0.id}", "${aws_subnet.public-subnet-1.id}", "${aws_subnet.public-subnet-2.id}"]
  min_size = 2
  max_size = 4
  load_balancers = ["${aws_elb.jalcalaroot-elb.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "jalcalaroot"
    propagate_at_launch = true
  }
}

# scale up alarm
resource "aws_autoscaling_policy" "cpu-policy-scaleup" {
name = "cpu-policy-scaleup"
autoscaling_group_name = "${aws_autoscaling_group.jalcalaroot.name}"
adjustment_type = "ChangeInCapacity"
scaling_adjustment = "1"
cooldown = "300"
policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scaleup" {
alarm_name = "cpu-alarm-scaleup"
alarm_description = "cpu-alarm-scaleup"
comparison_operator = "GreaterThanOrEqualToThreshold"
evaluation_periods = "2"
metric_name = "CPUUtilization"
namespace = "AWS/EC2"
period = "120"
statistic = "Average"
threshold = "90"
dimensions = {
"AutoScalingGroupName" = "${aws_autoscaling_group.jalcalaroot.name}"
}
actions_enabled = true
alarm_actions = ["${aws_autoscaling_policy.cpu-policy-scaleup.arn}"]
}

# scale down alarm
resource "aws_autoscaling_policy" "cpu-policy-scaledown" {
name = "cpu-policy-scaledown"
autoscaling_group_name = "${aws_autoscaling_group.jalcalaroot.name}"
adjustment_type = "ChangeInCapacity"
scaling_adjustment = "-1"
cooldown = "300"
policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scaledown" {
alarm_name = "cpu-alarm-scaledown"
alarm_description = "cpu-alarm-scaledown"
comparison_operator = "LessThanOrEqualToThreshold"
evaluation_periods = "2"
metric_name = "CPUUtilization"
namespace = "AWS/EC2"
period = "120"
statistic = "Average"
threshold = "90"
dimensions = {
"AutoScalingGroupName" = "${aws_autoscaling_group.jalcalaroot.name}"
}
actions_enabled = true
alarm_actions = ["${aws_autoscaling_policy.cpu-policy-scaledown.arn}"]
}

#--------------------------------------------------------
#ELB-sg

resource "aws_security_group" "elb-sg" {
  name = "elb-sg"
  description = "elb-sg"
  vpc_id      = "${aws_vpc.jalcalaroot.id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
# HTTP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
# https
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
# tomcat
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

# KAS
  ingress {
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    env  = "terraform"
    name = "elb-sg"
  }
}

resource "aws_elb" "jalcalaroot-elb" {
    name = "jalcalaroot-elb"
    subnets = ["${aws_subnet.public-subnet-0.id}", "${aws_subnet.public-subnet-1.id}", "${aws_subnet.public-subnet-2.id}"]
    security_groups = ["${aws_security_group.elb-sg.id}"]
    connection_draining = true
    connection_draining_timeout = 300
    
    listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
    lb_protocol = "http"
    }

    listener {
    lb_port = 8080
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
    lb_protocol = "http"
    }


    listener {
    instance_port = "9000"
    instance_protocol = "tcp"
    lb_port = 9000
    lb_protocol = "tcp"
    }
    

}

     output "elb_dns_name" {
     value = "${aws_elb.jalcalaroot-elb.dns_name}"
 }


