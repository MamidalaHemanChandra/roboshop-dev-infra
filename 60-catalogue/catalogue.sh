#!/bin/bash

component=$1
env=$2

dnf install ansible -y

# ansible-pull -U https://github.com/MamidalaHemanChandra/ansible-roboshop-roles-tf.git -e component=$component main.yaml

REPO_URL=https://github.com/MamidalaHemanChandra/ansible-roboshop-roles-tf.git
REPO_DIR=ansible-roboshop-roles-tf

mkdir -p /var/log/roboshop/
touch ansible.log

rm -rf $REPO_DIR

if [ -d $REPO_DIR ];then
    cd $REPO_DIR
    git pull
else
    git clone $REPO_URL
    cd $REPO_DIR
fi

ansible-playbook -e component=$component -e env=$env main.yaml
