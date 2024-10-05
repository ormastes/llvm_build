#!/bin/bash
cp -r ../dockerimg/keys/ keys
sudo docker image rm ubuntu-with-sshd
sudo docker build -t ubuntu-with-sshd .
rm -rf keys
