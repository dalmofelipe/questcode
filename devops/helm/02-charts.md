## HELM CHARTS

https://github.com/helm/chartmuseum


### CONFIGURANDO REGISTRY LOCAL DO CHARTMUSEUM NO K8S DEVOPS NAMESPACE

```bash
helm repo add chartmuseum https://chartmuseum.github.io/charts
# helm install my-chartmuseum chartmuseum/chartmuseum --version 3.7.1
# helm install --name helm --namespace devops -f 02-chartmuseum-conf.yaml stable/chartmuseum
helm install k8s-chartmuseum --namespace=devops -f 03-chartmuseum-config.yaml chartmuseum/chartmuseum
```


```yaml
# 03-chartmuseum-conf.yaml
env:
  open:
    STORAGE: local
    DISABLE_API: false
    ALLOW_OVERWRITE: true
service:
  type: NodePort
  nodePort: 30010
```


```yaml
export NODE_PORT=$(kubectl get --namespace devops -o jsonpath="{.spec.ports[0].nodePort}" services helm-chartmuseum)

export NODE_IP=$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}")

echo http://$NODE_IP:$NODE_PORT/

```


### PUSH DOS CHARTS LOCAIS PARA REGISTRY DO CHARTMUSEUM NO NAMESPACE 'DEVOPS'

### CM-PUSH

```sh
#!/bin/bash

# 03-chartmuseum.sh

# helm install helm --namespace=devops -f 03-chartmuseum-config.yaml chartmuseum/chartmuseum

# add helm-repo do k8s-chartmuseum
helm repo add questcode http://$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}"):30010

# install plugin helm-push
helm plugin install https://github.com/chartmuseum/helm-push

helm lint charts/frontend/
helm package charts/frontend/ -d oci/
helm cm-push oci/frontend-0.1.0.tgz http://localhost:30010

helm lint charts/backend-scm/
helm package charts/backend-scm/ -d oci/
helm cm-push oci/backend-scm-0.1.0.tgz http://localhost:30010

helm lint charts/backend-user/
helm package charts/backend-user/ -d oci/
helm cm-push oci/backend-user-0.1.0.tgz http://localhost:30010

helm repo update
```

    `Port` exposes the Kubernetes service on the specified port within the cluster. Other pods within the cluster can communicate with this server on the specified port.

    `TargetPort` is the port on which the service will send requests to, that your pod will be listening on. Your application in the container will need to be listening on this port also.

    `NodePort` exposes a service externally to the cluster by means of the target nodes IP address and the NodePort. NodePort is the default setting if the port field is not specified.



## RUNING AND HELM UPGRADE

Upgrade simulando nova versão do ```backend-scm```

```sh
# limpando todos charts instalados via arquivos
helm delete backend-scm backend-user frontend --namespace=staging

# re instalando via repository chartmuseum
helm install frontend questcode/frontend --namespace=staging
helm install backend-scm questcode/backend-scm --namespace=staging
helm install backend-user questcode/backend-user --namespace=staging

# novo deply de nova versão do app entregue pela equipe de dev
helm upgrade backend-scm questcode/backend-scm --set image.tag=0.1.1 --namespace=staging

# checar os status e historico de um chart
helm status backend-scm -n staging
helm history backend-scm -n staging

# ihh deu ruim, rollback para versão anterior
helm rollback <RELEASE> <REVISION>
helm rollback backend-scm 1 -n staging
```








### FRONTEND CHART BASIC

pasta-nome-chart

templates

Charts.yaml

values.yaml


```bash
helm create <nome-chart>
```

```bash
helm ls
helm ls -a
helm list --all-namespaces
```

```bash
helm delete <nome-chart>
```

'--purge' Just to note as of helm v3 --purge is default behaviour. You no longer need the flag

If you want to keep any history (aka the behaviour of helm 2.x's helm delete without the --purge flag) you now need to use --keep-history eg helm delete nginx-ingress --keep-history


```bash
helm install <nome-chart> --namespace=default .
```

'--set namespace=default' cria um key=value em 'values.yaml' do namespace onde o helm deve subir o chart no K8s

'.' o ponto indica o diretório atual


```bash
helm ls
```

```bash
helm upgrade --install
helm upgrade --install backend-scm --namespace=staging .
```

```bash
helm package charts/backend-user oci/
```
