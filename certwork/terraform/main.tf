variable "aws_region" {
  type = string
  default = "eu-central-1"
}

provider "aws" {
  region = var.aws_region
}

variable "ssh_key" {
  type = string
  default = "ssh_key"
}

variable "AWS_ACCESS_KEY_ID" {
  type = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}

variable "staging_web_port" {
  type = number
  default = 8080
}


resource "aws_instance" "build" {
  ami = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.build.id]
  key_name = var.ssh_key
  tags = {
    Name = "build"
  }
}

resource "aws_security_group" "build" {
  name = "build"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    
  }
}

resource "aws_instance" "staging" {
  ami = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.staging.id]
  key_name = var.ssh_key
  tags = {
    Name = "staging"
  }
}

resource "aws_security_group" "staging" {
  name = "staging"

  ingress {
    from_port = var.staging_web_port
    to_port = var.staging_web_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.ssh_key
  public_key = file(../keys/${ssh_key}.pub)
}

resource "aws_ecr_repository" "repository" {
  name = "app"
}

resource "aws_ecr_repository_policy" "repository_plicy" {
  repository = aws_ecr_repository.repository.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the demo repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

data "aws_caller_identity" "current" {
}

output "account_id" {
 value = data.aws_caller_identity.current
}

output "repository" {
  value = aws_ecr_repository.repository
}
