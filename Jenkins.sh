#!/bin/bash

# Update system and install Java
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

# Add Jenkins repository key
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update repo list
sudo apt update

# Install Jenkins
sudo apt install jenkins -y

# Start & enable Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Show Jenkins status
systemctl status jenkins
