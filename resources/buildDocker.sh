#!/bin/sh

aws secretsmanager get-secret-value --region us-east-1 --secret-id GitHub-Blaughton-PublicKey | jq '. | .SecretString' | sed 's/"//g' > /root/.ssh/id_rsa.pub
aws secretsmanager get-secret-value --region us-east-1 --secret-id GitHub-Blaughton-PrivateKey | jq '. | .SecretString' | sed 's/"//g' | sed 's/\\n/\n/g' > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa.pub /root/.ssh/id_rsa

ssh-keyscan github.com >> ~/.ssh/known_hosts

mkdir -p /tmp/workspace
cd /tmp/workspace
git clone git@github.com:blaughton/dockerbuild.git
cd dockerbuild
docker build -t project:latest .
