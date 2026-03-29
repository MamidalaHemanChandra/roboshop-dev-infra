#!/bin/bash

growpart /dev/nvme0n1 4
lvextend -L +50G /dev/mapper/RootVG-homeVol
xfs_growfs /home

sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install terraform