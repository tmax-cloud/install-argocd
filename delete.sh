#!/bin/bash

export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

kubectl delete -f $SCRIPT_DIR/manifests/install.yaml -n argocd

kubectl delete -f $SCRIPT_DIR/manifests/install-rollout.yaml -n argo-rollouts

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
   kubectl delete ns argocd
else
   echo "argocd namespace is not present"
fi

export namespaceStatus=$(kubectl get ns argo-rollouts -o json | jq .status.phase -r)
if [ $namespaceStatus == "Active" ]
then
   kubectl delete ns argo-rollouts
else
   echo "argo-rollouts namespace is not present"
fi

