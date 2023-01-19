#!/bin/bash
if [  -n "$(uname -a | grep Ubuntu)" ]; then
    sudo apt-get update && sudo apt-get upgrade     
    apt-get install python-pip
else
    yum update && yum upgrade
    yum install python-pip
fi

pip install bcrypt

export pwd=$(python -c 'import bcrypt; print(bcrypt.hashpw(b"admin", bcrypt.gensalt(rounds=15)).decode("ascii"))')

kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "'$pwd'",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
