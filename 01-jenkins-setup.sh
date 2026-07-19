#!/bin/bash

set -e

echo "========================================"
echo " Jenkins Installation Script"
echo " Ubuntu 24.04 LTS"
echo "========================================"

# Verify root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

echo ""
echo "Updating package repositories..."
apt update

echo ""
echo "Installing prerequisites..."
apt install -y \
    curl \
    wget \
    gnupg \
    ca-certificates \
    software-properties-common

echo ""
echo "Installing OpenJDK 17..."
apt install -y openjdk-17-jdk

echo ""
echo "Verifying Java installation..."
java -version

echo ""
echo "Removing any old Jenkins repository..."
rm -f /etc/apt/sources.list.d/jenkins.list
rm -f /usr/share/keyrings/jenkins-keyring.asc

echo ""
echo "Adding Jenkins GPG key..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
| tee /usr/share/keyrings/jenkins-keyring.asc >/dev/null

echo ""
echo "Adding Jenkins repository..."
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
> /etc/apt/sources.list.d/jenkins.list

echo ""
echo "Updating package repository..."
apt update

echo ""
echo "Installing Jenkins..."
apt install -y jenkins

echo ""
echo "Enabling Jenkins service..."
systemctl enable jenkins

echo ""
echo "Starting Jenkins..."
systemctl restart jenkins

echo ""
echo "Checking Jenkins status..."
systemctl --no-pager status jenkins

echo ""
echo "Checking if Jenkins is listening on port 8080..."
ss -tlnp | grep 8080 || true

echo ""
echo "========================================"
echo "Installed Versions"
echo "========================================"

echo ""
echo "Java:"
java -version

echo ""
echo "Jenkins:"
jenkins --version || true

echo ""
echo "========================================"
echo "Initial Admin Password"
echo "========================================"

cat /var/lib/jenkins/secrets/initialAdminPassword

echo ""
echo "========================================"
echo "Open Jenkins in your browser:"
echo ""
hostname -I | awk '{print "http://"$1":8080"}'
echo "========================================"
