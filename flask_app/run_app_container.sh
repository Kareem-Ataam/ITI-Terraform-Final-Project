#!/bin/bash
cd /home/ec2-user/flask-app

sudo docker rm -f flask-app || true
sudo docker rmi flask-sample-app || true

sudo docker build -t flask-sample-app .
sudo docker run -d --name flask-app -p 80:5000 flask-sample-app