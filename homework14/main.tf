provider "aws" {
  region = var.aws_region
}
variable "app_version" {
  type = string
  default = "latest"
}

variable "aws_region" {
  type = string
  default = "eu-central-1"
}

variable "production_web_port" {
  type = number
  default = 8080
}

variable "ssh_key" {
  type = string
  default = "ssh_key"
}

variable "instance_user" {
  type = string
  default = "ubuntu"
}

variable "AWS_ACCESS_KEY_ID" {
  type = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}


resource "aws_instance" "build" {
  ami = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.build.id]
  key_name = var.ssh_key
#  user_data = <<-EOF
#                #!/bin/bash
#                echo "hello world" > index.html
#                nohup busybox httpd -f -p ${var.example_http_port} &
#                EOF
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

resource "aws_instance" "production" {
  ami = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.production.id]
  key_name = var.ssh_key
  tags = {
    Name = "production"
  }
}

resource "aws_security_group" "production" {
  name = "production"

  ingress {
    from_port = var.production_web_port
    to_port = var.production_web_port
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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmZMj/wQC/pZ1ohe2JyKB76yuqvF0I+xEtcvyuaTDx9XxCnPN4Hjp8m3pfJdbmgpTgdB03WyMy+Z/B7OxT5VURtAlyW5LS6Qb1W1zR9Pl/mvhXqlgvYK003LSaag1z2O80TSyXVD9w2ewyQJ84NQ0encitM2/RJ35d0S4EjcH6pmEf/C4N4K4BfIG/7OnUJmUEtc8S82RNY39tkzMZqQVqwuRi3XLfrO+eO5+LSaLaYw1CSW3BiopPZP5//YDt0mitT5aJiO4ANOV+P2ynUVsYuojEYahRQCU4uZcmX+X0aI1m71+ldjnsoOpCxomoA0tdli24LwB4J/nF1sk6ZDJ1G9ZTsLR69pcRqWfujPXEeIqc7ExoZVGIOJhkC6QbaUefmgaaizzwa4GJhpfQVqrppJTopz8pqJirbyqtogCmuwO+ObRbxhuKA0fgmPrzfs9p0EmPvXRAXmLg31aooi8XtrtGpA/Hnh1d7ui+Xqp1QIqsZJlSZg43yAkVjE2BUVU= ubuntu@ip-172-31-37-199"
}

resource "null_resource" "build_trigger" {

  connection {
    type = "ssh"
    host = element(aws_instance.build.*.public_ip, 0)
    user = var.instance_user 
    private_key="${file("ssh_key")}"
    timeout = "3m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y git-core",
      "sudo apt install -y awscli",
      "sudo apt install -y docker.io",
      "export AWS_ACCESS_KEY_ID=${var.AWS_ACCESS_KEY_ID}",
      "export AWS_SECRET_ACCESS_KEY=${var.AWS_SECRET_ACCESS_KEY}",
      "export AWS_DEFAULT_REGION=${var.aws_region}",
      "aws ecr get-login-password --region ${var.aws_region} | sudo docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com",
      "rm -rf ${var.app_version}", 
      "git clone https://github.com/paladim/devops ${var.app_version}",
      "sudo docker build -f ${var.app_version}/homework11/ProjectBuildDockerfile . -t app-build:${var.app_version}",
      "sudo docker build -f ${var.app_version}/homework11/ProjectDeployDockerfile . -t app-deploy:${var.app_version}",
      "sudo docker tag app-deploy:${var.app_version} ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/app:${var.app_version}",
      "sudo docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/app:${var.app_version}",
    ]
  }

  triggers = {
   always_run = timestamp()
  }
}

resource "null_resource" "production_trigger" {

  connection {
    type = "ssh"
    host = element(aws_instance.production.*.public_ip, 0)
    user = var.instance_user
    private_key="${file("ssh_key")}"
    timeout = "3m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y git-core",
      "sudo apt install -y awscli",
      "sudo apt install -y docker.io",
      "export AWS_ACCESS_KEY_ID=${var.AWS_ACCESS_KEY_ID}",
      "export AWS_SECRET_ACCESS_KEY=${var.AWS_SECRET_ACCESS_KEY}",
      "export AWS_DEFAULT_REGION=${var.aws_region}",
      "aws ecr get-login-password --region ${var.aws_region} | sudo docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com",
      "rm -rf ${var.app_version}", 
      "sudo docker rm app -f", 
      "sudo docker pull ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/app:${var.app_version}",
      "sudo docker run -d -p ${var.production_web_port}:8080 --name app ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/app:${var.app_version}",
    ]
  }

  triggers = {
   always_run = timestamp()
  }

  depends_on = [
    null_resource.build_trigger,
  ]
  
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
