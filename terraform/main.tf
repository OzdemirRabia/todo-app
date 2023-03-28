terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
}





resource "aws_security_group" "tf-server-sec-gr" {
  name = "server-sec-gr" 
  tags = {
    Name = "server-sec-gr"
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks= ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks= ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks= ["0.0.0.0/0"]
  }
}


resource "aws_launch_template" "asg-lt" {
  name = "todo-app-server"
  image_id = "ami-0e067cc8a2b58de59"
  instance_type = "t3.medium"
  key_name = "rabia"
  vpc_security_group_ids = [aws_security_group.tf-server-sec-gr.id]
  tags = {
    Name = "rabia-todo-app"
  }
  user_data = filebase64("user-data.sh")

}







resource "aws_security_group" "alb-sg" {
  name = "ALBSecurityGroup"
  tags = {
    Name = "TF_ALBSecurityGroup"
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_alb_target_group" "app-lb-tg" {
  name = "todo-app-lb-tg"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = "vpc-2ff7f844"
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}




resource "aws_alb" "app-lb" {
  name = "todo-app-lb-tf"
  ip_address_type = "ipv4"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb-sg.id]
  subnets = ["subnet-a92d1de4", "subnet-541a3729"]
}


resource "aws_alb_listener" "app-listener" {
  load_balancer_arn = aws_alb.app-lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.app-lb-tg.arn
  }
}


resource "aws_autoscaling_group" "app-asg" {
  max_size = 3
  min_size = 1
  desired_capacity = 1
  name = "todo-app-asg"
  health_check_grace_period = 300
  health_check_type = "ELB"
  target_group_arns = [aws_alb_target_group.app-lb-tg.arn]
  vpc_zone_identifier = aws_alb.app-lb.subnets

  launch_template {
    id = aws_launch_template.asg-lt.id
    version = aws_launch_template.asg-lt.latest_version
  }
}

output "websiteurl" {
  value = "http://${aws_alb.app-lb.dns_name}"
}

