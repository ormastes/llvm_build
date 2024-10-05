#!/bin/bash
sudo docker stop build
sudo docker rm build

# --privileged is needed for some demon process.
# /home/ormastes/dev:/workspace/dev can be change for each environment.
sudo docker run --privileged --name build -p 7822:22 -v /home/ormastes/dev:/workspace/dev -it ubuntu-with-sshd bash
