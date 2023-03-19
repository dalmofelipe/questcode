#!/bin/bash

# 03-chartmuseum.sh

helm install helm --namespace=devops -f 03-chartmuseum-config.yaml chartmuseum/chartmuseum

helm repo add questcode http://$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}"):30010

helm plugin install https://github.com/chartmuseum/helm-push

helm lint charts/frontend/
helm push charts/frontend/ questcode

helm lint charts/backend-scm/
helm push charts/backend-scm/ questcode

helm lint charts/backend-user/
helm push charts/backend-user/ questcode

helm repo update