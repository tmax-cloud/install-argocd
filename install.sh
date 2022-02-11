#!/bin/bash

MANIFEST_DIR="manifests"

kubectl apply -f ${MANIFEST_DIR}/argocd-crd.yaml 
kubectl apply -f ${MANIFEST_DIR}/argocd-ns.yaml
kubectl apply -f ${MANIFEST_DIR}/argocd-rbac.yaml
kubectl apply -f ${MANIFEST_DIR}/argocd-cm.yaml
kubectl apply -f ${MANIFEST_DIR}/argocd-secret.yaml
kubectl apply -f ${MANIFEST_DIR}/argocd-svc.yaml
kubectl apply -f ${MANIFEST_DIR}/argocd-deploy-and-sts.yaml
kubectl apply -f ${MANIFEST_DIR}/argocd-network-policy.yaml
