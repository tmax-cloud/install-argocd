#!/bin/bash

pip3 install fnvhash

# Set Env
ARGOCD_NAMESPACE="argocd"
REPO_URL="https://gitlab.gitlab-system.172.21.5.210.nip.io/root/argocd-installer.git"
USERNAME="admin@example.com"
PASSWORD="qwer12345!"
SECRET_MANIFEST="repo-secret.yaml"

# Generate repository secret
SECRET_NAME=`python3 gen-secret-name.py $REPO_URL`

# Encode base64
BASE64_REPO_URL=$(echo $(echo -n $REPO_URL | base64) | tr -d ' ')
BASE64_USERNAME=$(echo $(echo -n $USERNAME | base64) | tr -d ' ')
BASE64_PASSWORD=$(echo $(echo -n $PASSWORD | base64) | tr -d ' ')

sed -i "s|{{ secret_name }}|${SECRET_NAME}|g" ${SECRET_MANIFEST}
sed -i "s|{{ argocd_namespace }}|${ARGOCD_NAMESPACE}|g" ${SECRET_MANIFEST}
sed -i "s|{{ repo_url }}|${BASE64_REPO_URL}|g" ${SECRET_MANIFEST}
sed -i "s|{{ username }}|${BASE64_USERNAME}|g" ${SECRET_MANIFEST}
sed -i "s|{{ password }}|${BASE64_PASSWORD}|g" ${SECRET_MANIFEST}

kubectl apply -f $SECRET_MANIFEST
