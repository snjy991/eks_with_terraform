#!/bin/bash
case "${1}" in
   deploy)
   echo "Deploying argocd"
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
   ;;
   destroy)
   echo "Destroying argocd"
   kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   kubectl delete namespace argocd
   ;;
   showpassword)
   echo "argo cd login password"
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
   ;;
esac