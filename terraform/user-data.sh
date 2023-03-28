#! /bin/bash
apt-get update
apt-get upgrade
apt install docker.io -y
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mkdir -p /home/ubuntu/basic-todo-app
TOKEN="XXXXXXXXXXXXXXX"
FOLDER="https://$TOKEN@raw.githubusercontent.com/OzdemirRabia/basic-todo-app/main/"
curl -s --create-dirs -o "home/ubuntu/basic-todo-app/requirements.txt" -L "$FOLDER"requirements.txt
curl -s --create-dirs -o "home/ubuntu/basic-todo-app/to-do-api.py" -L "$FOLDER"to-do-api.py
curl -s --create-dirs -o "home/ubuntu/basic-todo-app/Dockerfile" -L "$FOLDER"Dockerfile
curl -s --create-dirs -o "home/ubuntu/basic-todo-app/docker-compose.yaml" -L "$FOLDER"docker-compose.yaml
cd home/ubuntu/basic-todo-app
docker-compose up -d


