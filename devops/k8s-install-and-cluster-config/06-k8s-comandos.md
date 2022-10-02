### LISTA DE COMANDOS K8S


```bash

# Aplica um arquivo de configuração ao server
kubectl apply -f <filename> 

# Lista todos recursos em todos namespaces
kubectl get all --all-namespaces 

# para editar enquanto esta em execução
kubectl edit svc <service_name> -n <namespace>

kubectl logs pod/backend-scm-78c94d4d76-r87h6 -n staging

kubectl describe pod/backend-scm-78c94d4d76-r87h6 -n staging

```


### STOP CLUSTER


```bash

sudo systemctl stop kubelet cri-docker cri-docker.socket

# esse comando parará todos os containers do host
docker stop $(docker ps -qa)

sudo systemctl stop docker docker.socket containerd 

```


### START CLUSTER


```bash

sudo systemctl start docker docker.socket containerd 

sudo systemctl start cri-docker cri-docker.socket

sudo systemctl start kubelet

```