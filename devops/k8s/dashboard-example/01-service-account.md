
kubectl apply -f dashboard-adminuser.yaml

kubectl proxy

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

kubectl -n kubernetes-dashboard create token admin-user
