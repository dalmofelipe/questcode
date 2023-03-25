# DASHBOARD


## Deploy descricao do deployment

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
```


## Criar NodePort para expor o deployment

```bash
kubectl expose deployment kubernetes-dashboard --name=kubernetes-dashboard-nodeport --port=443 --target-port=8443 --type=NodePort -n kube-system
```

Arquivo com a especifição do NodePort acima

```yaml
# nodeport-deployment.yaml

kind: Service
apiVersion: v1
metadata:
  name: kubernetes-dashboard-nodeport-yaml
spec:
  type: NodePort
  selector:
    k8s-app: kubernetes-dashboard
  ports:
  - protocol: TCP
    port: 443
    targetPort: 8443
```

Rode o comando kubectl apply para aplicar as configurações do NodePort

```bash
kubectl apply -f nodeport-deployment.yaml
```


## Criando Service Account e associando permissao 'cluster-admin'

```bash
kubectl create serviceaccount kubeadmin -n kube-system 
kubectl create clusterrolebinding kubeadmin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:kubeadmin

kubectl describe sa kubeadmin -n kube-system
kubectl get secret <TOKEN-ID> -n kube-system -o yaml
echo `echo <TOKEN> | base64 --decode`
```


# Excluindo DASHBOARD

kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml