# HELM CHARTS

### EXEMPLO CRIANDO UM HELM CHART DO FRONTEND

Minimo necessário para criar um Helm Chart!

    frontend-basic
    .
    ├── Chart.yaml
    ├── templates
    │   ├── deployment.yaml
    │   └── service.yaml
    └── values.yaml

Template completo de Helm Chart pode ser criado pelo comando create.

```bash
helm create <nome-chart>
```



### PORTS DE UM CLUSTER K8S

`NodePort` exposes a service externally to the cluster by means of the target nodes IP address and the NodePort. NodePort is the default setting if the port field is not specified.

by tradutor: 
Atende a solicitação externa em todos os nós do trabalhador em nodeip:nodeport e encaminha a solicitação para a porta.

o que entendi: porta externa, que irá expor o namespace para web


`Port` exposes the Kubernetes service on the specified port within the cluster. Other pods within the cluster can communicate with this server on the specified port.

by tradutor: 
Porta de serviço de cluster interno para contêiner e escuta a solicitação de entrada do nodeport e encaminha para targetPort.

o que entendi: porta que a aplicação foi codificada e ouvindo;


`TargetPort` is the port on which the service will send requests to, that your pod will be listening on. Your application in the container will need to be listening on this port also.

by tradutor: 
Recebe a solicitação da porta e encaminha para o contêiner pod(porta) onde está escutando. Mesmo se você não especificar isso, receberá por padrão os mesmos números de porta como porta.


`ClusterIP`: a solicitação vem por meio de entrada e aponta para o nome e a porta do serviço.

o que entedi: porta de comunicação interna entre os pods


Então o tráfego flui Ingress-->Service-->Endpoint (Basicamente tem POD IP)->POD


### PUSH DOS CHARTS LOCAIS PARA REGISTRY DO CHARTMUSEUM NO NAMESPACE 'DEVOPS'

### CM-PUSH

```sh
#!/bin/bash

# chartmuseum.sh

# helm install helm --namespace=devops -f chartmuseum-config.yaml chartmuseum/chartmuseum

# add helm-repo do k8s-chartmuseum
helm repo add questcode http://$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}"):30010
ou
helm repo add questcode http://<IP-HOST-CLUSTER>:30010


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


## RUNING AND HELM UPGRADE

Upgrade simulando nova versão do ```backend-scm```

```sh
# instalando via repository chartmuseum
helm install frontend questcode/frontend --namespace=staging
helm install backend-scm questcode/backend-scm --namespace=staging
helm install backend-user questcode/backend-user --namespace=staging

# limpando todos charts instalados via arquivos
helm delete backend-scm backend-user frontend --namespace=staging

# novo deply de nova versão do app entregue pela equipe de dev
helm upgrade backend-scm questcode/backend-scm --set image.tag=0.1.1 --namespace=staging

# checar os status e historico de um chart
helm status backend-scm -n staging
helm history backend-scm -n staging

# ihh deu ruim, rollback para versão anterior
helm rollback <RELEASE> <REVISION>
helm rollback backend-scm 1 -n staging
```
