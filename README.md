# DevOps BootCamp - QuestCode

![Bootcamp DevOps](/docs/cover.png "Bootcamp DevOps")

## RoadMap





# DOCKER

## Instalação

```bash
sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -aG docker $USER
```
<br>

# KUBERNETES K8S

## Remover todas configurações de clusters anteriores

```bash
systemctl stop cri-docker.service cri-docker.socket kubelet.service

kubeadm reset cleanup-node

rm -rf /var/lib/etcd  \
&& rm -rf /var/lib/kubelet  \
&& rm -rf /var/lib/dockershim  \
&& rm -rf /var/run/kubernetes  \
&& rm -rf /var/lib/cni \
&& rm -f /etc/cni/net.d/10-flannel.conflist \
&& rm -f /opt/cni/bin/flannel \
&& rm -rf /etc/cni/net.d \
&& rm -f $HOME/.kube

iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
```

## Compilar, instalar e configurar CRI-Dockerd

```bash
sudo su 

wget https://storage.googleapis.com/golang/getgo/installer_linux
chmod +x ./installer_linux
./installer_linux
source ~/.bash_profile

git clone https://github.com/Mirantis/cri-dockerd.git

cd cri-dockerd

mkdir bin

go build -o bin/cri-dockerd

mkdir -p /usr/local/bin

install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd

cp -a packaging/systemd/* /etc/systemd/system

sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service

systemctl daemon-reload
systemctl enable cri-docker.service
systemctl enable --now cri-docker.socket

systemctl status cri-docker.service
```

## Configurar rede e desativar swap

```bash
sudo su

modprobe br-netfilter

sysctl -w net.bridge.bridge-nf-call-iptables=1

echo 1 > /proc/sys/net/ipv4/ip_forward

echo "br-netfilter" >> /etc/modules-load.d/modules.conf
```


## Instalando Kubernetes e iniciando Cluster Local - Bare Metal

```bash
sudo su
swapon -s
swapoff -a

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```


## INICIALIZAR CLUSTER

```bash
kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubeadm join 192.168.0.231:6443 --token 7yow72.n9696or3dijmumj5 --discovery-token-ca-cert-hash sha256:0e8c2f7020c14e48897b4d0edfbbdb760ad0c8fb4a6379fd5bb8916bb27f79cb 
```


## CONTROL-PLANE ISOLATION

Permite que o master/control-plane rode como um node!

```bash
# libera o master para agir como worker
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```


## Aplicar yaml de namespaces

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: prod
---
apiVersion: v1
kind: Namespace
metadata:
  name: staging
---
apiVersion: v1
kind: Namespace
metadata:
  name: devops

```


# DOCKER BUILD IMAGES E DOCKER REGISTRY

## FRONTEND

```bash
docker build -t --name frontend-alpine-staging dalmofelipe/questcode-frontend:0.1.0-staging --build-arg NPM_ENV=staging .
docker push dalmofelipe/dalmofelipe/questcode-frontend:0.1.0-staging
```

Caso o container não tenha acesso a internet para baixar as dependências pelo npm, use a flag *--network host*

```bash
docker build -t --name frontend-alpine-staging dalmofelipe/questcode-frontend:0.1.0-staging --build-arg NPM_ENV=staging --network host .
```

## SCM

```bash
docker build -t dalmofelipe/questcode-backend-scm:0.1.0-staging .
docker push dalmofelipe/questcode-backend-scm:0.1.0-staging 
```

## USER

```bash
docker build -t dalmofelipe/questcode-backend-user:0.1.0-staging .
docker push dalmofelipe/questcode-backend-user:0.1.0-staging 
```


# HELM

## Instalar Helm no computador local/HOST

```bash
# helm install , caso já tenha o Helm instalado ele será atualizado
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh

# Adicionar repositorio do Char do Chartmuseum no Host
helm repo add chartmuseum https://chartmuseum.github.io/charts
```


## Subir o Chartmuseum via HelmChart no cluster

```bash
# Aplicar HelmChart do Chartmuseum no Cluster
helm install k8s-chartmuseum --namespace=devops -f 03-chartmuseum-config.yaml chartmuseum/chartmuseum
```

Arquivo yaml do service

```yaml
# 03-charmuseum-config.yaml
env:
  open:
    STORAGE: local
    DISABLE_API: false
    ALLOW_OVERWRITE: true
service:
  type: NodePort
  nodePort: 30010
```

Após aplicar o procedimento acima, terá essa saida:

```
NAME: k8s-chartmuseum
LAST DEPLOYED: Sun Mar 19 15:32:26 2023
NAMESPACE: devops
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
** Please be patient while the chart is being deployed **

Get the ChartMuseum URL by running:

export NODE_PORT=$(kubectl get --namespace devops -o jsonpath="{.spec.ports[0].nodePort}" services k8s-chartmuseum)
export NODE_IP=$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT/
```

Acesse: http://<IP-COMPUTADOR-HOST>:30010/

Feito, Chartmuseum hospedado no Cluster!



## CRIANDO HELM CHARTS - TRANSFORMANDO IMAGENS DOCKER EM CHARTS 

Comando gera um template completo de Helm Chart.

```bash
# ./devops/helm/charts/questcode
cd ./devops/helm/charts/questcode

helm create <nome-chart>

# Ex
helm create frontend
```

```
  frontend/
  ├── charts
  ├── Chart.yaml
  ├── templates
  │   ├── deployment.yaml
  │   ├── _helpers.tpl
  │   ├── hpa.yaml
  │   ├── ingress.yaml
  │   ├── NOTES.txt
  │   ├── serviceaccount.yaml
  │   ├── service.yaml
  │   └── tests
  │       └── test-connection.yaml
  └── values.yaml
```

<br>

### Ports K8S no contexto do Helm Charts

`port`: port interna do cluster para comunicação entre aplicações

`targetPort`: Porta do container que a aplicação esta ouvindo. `containerPort` no deployment.yaml do Helm Chart

`nodePort`: Porta de saida do cluster K8S 

`ClusterIP`: Endereço para comunicação dos serviços internamento no cluster

`NodePort`: Porta externa para acessar os servicos internos do cluster

`LoadBalancer`: Porta externa para acessar os servicos internos do cluster pela nuvem 

<br>


### Estrutura do Helm Chart

<br>

**FRONTEND**

`frontend/values.yaml` - lorem  

`frontend/template/service.yaml` - lorem  

`frontend/template/deployment.yaml` - lorem  

<br>

**BACKEND-USER**

`backend-user/values.yaml` - lorem  

`backend-user/template/service.yaml` - lorem  

`backend-user/template/deployment.yaml` - lorem  

<br>

**BACKEND-SCM**

`backend-scm/values.yaml` - lorem  

`backend-scm/template/service.yaml` - lorem  

`backend-scm/template/deployment.yaml` - lorem  

<br>

### Instalar Chart direto da especificação pelo terminal para teste no K8S

```bash
# /devops/helm/charts/questcode/frontend
helm install frontend -n devops . # ponto no final

# listar Charts instalados pelo Helm
helm ls
helm ls -n devops

# Desinstalar um Chart 
helm uninstall frontend -n devops
```
<br>



WIP wip W I P w i p 




<br>

## SUBIR HELM CHARTS QUESTCODE PARA REGISTRY DO CHATMUSEUM NO CLUSTER

<br>

### ADD REPO DO QUESTCODE NO HELM CHARTMUSEUM DO CLUSTER K8S

```bash
# Adiciona repositorio de charts do Questcode no Helm Host local
helm repo add questcode http://$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}"):30010

# Atualizando lista de repositorios
helm repo update

# Lista repositórios
helm repo list

  NAME            URL                                 
  chartmuseum     https://chartmuseum.github.io/charts
  questcode       http://<IP-DO-HOST>:30010          

# Instalar o plug in CM-PUSH necessário para o upload dos charts do questcode para o cluster
helm plugin install https://github.com/chartmuseum/helm-push
```

<br>

### UPLOAD HELM CHART QUESTCODE

```bash
helm lint devops/helm/charts/questcode/frontend/
helm cm-push devops/helm/charts/questcode/frontend/ questcode

helm lint devops/helm/charts/questcode/backend-user/
helm cm-push devops/helm/charts/questcode/backend-user/ questcode

helm lint devops/helm/charts/questcode/backend-scm/
helm cm-push devops/helm/charts/questcode/backend-scm/ questcode

helm repo update
```

<br>

### RUNING AND HELM UPGRADE

Upgrade simulando nova versão do ```backend-scm```

```sh
# instalando microservicos do questcode via repository chartmuseum
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


# JENKINS

### Ordem de instalação do Jenkins

1 - Primeiro é obrigatório criar o PersistenceVolume e PersistenceVolumeClaim no namespace devops.

2 - Criar pasta no caminho ```/mnt/data-jenkins``` na maquina do HOST do cluster. Aplicar permissões via root!

3 - Adicionar o helm repo do Jenkins no Helm local

3 - Instalar Jenkins via HelmChart ```jenkins/jenkins```

<br>

### PERSISTENCE VOLUME pv E PERSISTENCE VOLUME CLAIMS pvc

**PRÉ REQUISITO PARA INSTALAR E CONFIGURAR O JENKINS!**

```yaml
# 01-pc-pvc.yaml
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: jenkins
  labels:
    type: local
spec:
  storageClassName: manual-for-jenkins
  capacity:
    storage: 16Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data-jenkins"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: jenkins
  namespace: devops
spec:
  storageClassName: manual-for-jenkins
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 16Gi
```

```bash
# cria o pv e pvc no namespace devops
kubectl apply -f 01-pc-pvc.yaml
```

<br>

### CRIAR DITORIO DO VOLUME NO SERVIDOR LOCAL/HOST DO CLUTER K8S

```bash
sudo mkdir /mnt/data-jenkins

sudo chown 1000:1000 /mnt/data-jenkins

watch ls -latr /mnt/data-jenkins
```

<br>

### JENKINS HELM CHART

Chart ```stable/jenkins``` foi descontinuado

- DEPRECATED - https://github.com/helm/charts/tree/master/stable/jenkins

Chart ```jenkins/jenkins``` utilizado

- https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/README.md

- https://charts.jenkins.io/?msclkid=4c3e5e79c40b11eca38222c6faeec1bf

```bash
# add repo do helm-jenkins
helm repo add jenkins https://charts.jenkins.io
helm repo update
```

<br>

### INSTALAÇÃO JENKINS VIA HELM

```bash
helm install jenkins jenkins/jenkins --set persistence.existingClaim=jenkins --set controller.serviceType=NodePort --set controller.nodePort=32090 --namespace=devops 

helm delete jenkins -n devops

helm upgrade jenkins jenkins/jenkins --set persistence.existingClaim=jenkins --set controller.serviceType=NodePort --set controller.nodePort=32090 --namespace=devops
```

**RESUMO DE VARIÁVEIS PARA PERSONALIZAR CONFIGURAÇÃO DO JENKINS**

https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/VALUES_SUMMARY.md


**LOG DO CHART JENKINS**

    controller.serviceType=NodePort --set controller.nodePort=32090 --namespace=devops
    NAME: jenkins
    LAST DEPLOYED: Fri Jun  2 11:22:50 2023
    NAMESPACE: devops
    STATUS: deployed
    REVISION: 1
    NOTES:
    1. Get your 'admin' user password by running:
    kubectl exec --namespace devops -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
    2. Get the Jenkins URL to visit by running these commands in the same shell:
    export NODE_PORT=$(kubectl get --namespace devops -o jsonpath="{.spec.ports[0].nodePort}" services jenkins)
    export NODE_IP=$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}")
    echo http://$NODE_IP:$NODE_PORT

    3. Login with the password from step 1 and the username: admin
    4. Configure security realm and authorization strategy
    5. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http://$NODE_IP:$NODE_PORT/configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos

    For more information on running Jenkins on Kubernetes, visit:
    https://cloud.google.com/solutions/jenkins-on-container-engine

    For more information about Jenkins Configuration as Code, visit:
    https://jenkins.io/projects/jcasc/


    NOTE: Consider using a custom image with pre-installed plugins

<br>

### LOGIN DASHBOARD JENKINS

```bash
# INFORMAÇÕES DO DEPLOY DO CHART
helm status jenkins -n devops

# DECIFRAR SENHA ADMIN DO JENKINS
kubectl exec --namespace devops -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

# SAIDA
buNoBBH0L8gLFlZdvGcbzm

export NODE_PORT=$(kubectl get --namespace devops -o jsonpath="{.spec.ports[0].nodePort}" services jenkins)
export NODE_IP=$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT

# SAIDA
http://<IP-HOST>:32090

```

- LOGIN: admin
- SENHA: buNoBBH0L8gLFlZdvGcbzm

<br>

### PERMISSIONAMENTO PARA JENKINS

O Jenkins precisar de permissões para manipular os services e pods no k8s, tanto no namespace devops quanto no kube-system!

```bash
kubectl create rolebinding sa-devops-role-clusteradmin --clusterrole=cluster-admin --serviceaccount=devops:default --namespace=devops

kubectl create rolebinding sa-devops-role-clusteradmin-kubesystem --clusterrole=cluster-admin --serviceaccount=devops:default --namespace=kube-system
```


<br>

### DOCUMENTAÇÃO OFICIAL DO JENKINS PARA INSTALAÇÃO NO K8S

- https://www.jenkins.io/doc/book/installing/kubernetes/

