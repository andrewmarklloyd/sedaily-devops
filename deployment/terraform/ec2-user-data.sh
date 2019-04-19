#!/bin/bash
yum update -y
yum install -y docker git
service docker start
usermod -a -G docker ec2-user
curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mkdir -p /home/ec2-user/app/backup
curl https://raw.githubusercontent.com/andrewmarklloyd/sedaily-devops/feature/deployment/deployment/assets/docker-compose.yml > /home/ec2-user/app/docker-compose.yml
chown -R ec2-user:ec2-user /home/ec2-user/app
