#!/bin/bash
if [  -n "$(uname -a | grep Ubuntu)" ]; then
    sudo apt-get update && sudo apt-get upgrade
    apt-get install jq -y
else
    yum update && yum upgrade
    yum install jq -y
fi

export namespaceStatus=$(kubectl get ns argocd -o json | jq .status.phase -r)
if [ $namespaceStatus == "Active" ]
then
   echo "argocd namespace is present"
else
   kubectl create ns argocd
fi

export namespaceStatus=$(kubectl get ns argo-rollouts -o json | jq .status.phase -r)
if [ $namespaceStatus == "Active" ]
then
   echo "argo-rollouts namespace is present"
else
   kubectl create ns argo-rollouts
fi

export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

kubectl apply -f $SCRIPT_DIR/manifests/install.yaml -n argocd

kubectl apply -f $SCRIPT_DIR/manifests/install-rollout.yaml -n argo-rollouts

