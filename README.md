# DevOps BootCamp - QuestCode

Passo a passo aplicado do curso Udemy - [Missão DevOps](http://missaodevops.com.br/docs/warrior_home.html)

O curso foi gravado segundo semestre de 2018, porem ainda é possivel acompanhar-lo, substituindo algumas ferramentas e muito stackoverflow.

<br>

## DOCKER

### INSTALAÇÃO

```bash
sudo su

apt-get update

apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

usermod -aG docker $USER
```
<br>

## KUBERNETES INSTALAÇÃO E INICIANDO CLUSTER

### REMOVER TODAS CONFIGURAÇÕES DE CLUSTERS ANTERIORES

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

### CRI-DOCKERD 

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

### HOST - CONFIGURAR REDE E DESATIVAR SWAP

```bash
sudo su

# rede
modprobe br-netfilter
sysctl -w net.bridge.bridge-nf-call-iptables=1
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "br-netfilter" >> /etc/modules-load.d/modules.conf

# Desabilitando o SWAP
swapon -s
swapoff -a
```

### INSTALAÇÃO KUBEADM, KUBELET E KUBECTL

```bash
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# IMPORTANTE! Caso esteja rodando diferentes de versões dessas ferramentas, pode perder comunicação com cluster.
sudo apt-mark hold kubelet kubeadm kubectl
```

### INICIALIZAR CLUSTER

```bash
kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubeadm join 192.168.0.231:6443 --token 7yow72.n9696or3dijmumj5 --discovery-token-ca-cert-hash sha256:0e8c2f7020c14e48897b4d0edfbbdb760ad0c8fb4a6379fd5bb8916bb27f79cb 
```

### MASTER/CONTROL-PLANE ISOLATION

Permite que o master/control-plane trabalhe como um node!

```bash
# libera o master para agir como worker
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

### QUESTCODE NAMESPACES

Neste ponto, após inicialização do cluster podemos iniciar implantação do Questcode. Passo importante, pois as proximas ferramentas serão configuradas no namespace `devops`


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

## HELM

```helm``` - CLI instalada na maquina local que hospeda o cluster k8s

```helm chart``` - Conjunto de especificações yaml para criar um chart de uma aplicação

```chartmuseum``` - Servidor de charts instalado no cluster k8s

<br>

### HELM CLI - LOCAL/HOST

```bash
# helm install , caso já tenha o Helm instalado ele será atualizado
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh

# Adicionar repositório do Char do Chartmuseum no Host
helm repo add chartmuseum https://chartmuseum.github.io/charts
```

### CHARTMUSEUM - REPOSITÓRIO DE CHARTS INSTALADO NO CLUSTER K8S

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

```bash
# Aplicar HelmChart do Chartmuseum no Cluster
helm install k8s-chartmuseum --namespace=devops -f 03-chartmuseum-config.yaml chartmuseum/chartmuseum
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

Acesse: http://IP-COMPUTADOR-HOST:30010/

Feito, Chartmuseum hospedado no Cluster!

<br>

## GERAR IMAGENS DOCKER DAS APLICAÇÕES E ENVIAR PARA DOCKER REGISTRY

Antes de criar HelmCharts do projeto é necessário gerar imagens docker dos 3 servicos da aplicação e armazena-las no registry (docker hub)

TODO - descrever comportamento do projeto em cada namespace do k8s e suas variaveis de ambiente

### FRONTEND

```bash
docker build -t --name frontend-alpine-staging dalmofelipe/questcode-frontend:0.1.0-staging --build-arg NPM_ENV=staging .
docker push dalmofelipe/questcode-frontend:0.1.0-staging
```

**Caso o container não tenha acesso a internet para baixar as dependências pelo npm, use a flag `--network host`**

```bash
docker build -t --name frontend-alpine-staging dalmofelipe/questcode-frontend:0.1.0-staging --build-arg NPM_ENV=staging --network host .
```

### SCM

```bash
docker build -t dalmofelipe/questcode-backend-scm:0.1.0-staging .
docker push dalmofelipe/questcode-backend-scm:0.1.0-staging 
```

### USER

```bash
docker build -t dalmofelipe/questcode-backend-user:0.1.0-staging .
docker push dalmofelipe/questcode-backend-user:0.1.0-staging 
```

<br>

## HELM CHARTS - TRANSFORMANDO IMAGENS DOCKER EM CHARTS 

### HELM CREATE

O comando `create` gera uma estrutura de diretórios e arquivos yaml, necessário para criar um Chart

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

### PORTS K8S NO CONTEXTO DO HELM CHARTS

`port`: port interna do cluster para comunicação entre aplicações

`targetPort`: Porta do pod/container que a aplicação esta ouvindo. `containerPort` no deployment.yaml do Helm Chart

`NodePort`: Porta externa para acessar os servicos internos do cluster

`ClusterIP`: Endereço IP para comunicação dos serviços internamento no cluster

`LoadBalancer`: Porta externa para acessar os servicos internos do cluster pela nuvem.

### ESTRUTURA DO HELM CHART

**FRONTEND**

`frontend/values.yaml`

`frontend/template/service.yaml`

`frontend/template/deployment.yaml`

**BACKEND-USER**

`backend-user/values.yaml`

`backend-user/template/service.yaml`

`backend-user/template/deployment.yaml`

**BACKEND-SCM**

`backend-scm/values.yaml`

`backend-scm/template/service.yaml`

`backend-scm/template/deployment.yaml`


### INSTALAÇÃO TESTE UM CHART

Neste ponto ainda não foi gerado um Chart. Isso serve apenas para teste da aplicação no cluster, antes de gerar o Chart de alguma versão do app.

```bash
# /devops/helm/charts/questcode/frontend
helm install frontend -n devops . # ponto no final

# listar Charts instalados pelo Helm
helm ls
helm ls -n devops

# Desinstalar um Chart 
helm uninstall frontend -n devops
```

### CRIAR REPOSITÓRIO DE CHARTS DO QUESTCODE NO CHARTMUSEUM INSTALADO NO CLUSTER

```bash
# Adiciona repositório de charts do Questcode no Helm Host local
helm repo add questcode http://$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}"):30010

# Atualizando lista de repositórios
helm repo update

# Lista repositórios
helm repo list

  NAME            URL                                 
  chartmuseum     https://chartmuseum.github.io/charts
  questcode       http://<IP-DO-HOST>:30010
```

### CM-PUSH - GERANDO CHART QUESTCODE E IMPLANTAR/DEPLOY NO CHARTMUSEUM DO CLUSTER

```bash
# Instalar o plug in CM-PUSH necessário para o upload dos charts do questcode para o cluster
helm plugin install https://github.com/chartmuseum/helm-push
```

```bash
# o comando lint valida a sintaxe de todos os arquivos yaml do diretorio de um chart
helm lint devops/helm/charts/questcode/frontend/

# o plugin cm-push gera um Chart das especificações contidas no ditorio e envia para o Chartmuseum no cluster
helm cm-push devops/helm/charts/questcode/frontend/ questcode

helm lint devops/helm/charts/questcode/backend-user/
helm cm-push devops/helm/charts/questcode/backend-user/ questcode

helm lint devops/helm/charts/questcode/backend-scm/
helm cm-push devops/helm/charts/questcode/backend-scm/ questcode

helm repo update
```

### QUESTCODE RUNING E UPGRADE

```sh
# instalando microservicos do questcode via repository chartmuseum
helm install frontend questcode/frontend --namespace=staging
helm install backend-scm questcode/backend-scm --namespace=staging
helm install backend-user questcode/backend-user --namespace=staging

# UPGRADE DE UM CHART
# NOVO DEPLY DE NOVA VERSÃO DO APP ENTREGUE PELA EQUIPE DE DEV
# PARA ESTE PASSO É NECESSÁRIO GERAR UMA NOVA TAG DA IMAGEM DOCKER DO SCM
helm upgrade backend-scm questcode/backend-scm --set image.tag=0.1.1 --namespace=staging

# checar os status e historico de um chart
helm status backend-scm -n staging
helm history backend-scm -n staging

# ihh deu ruim, rollback para versão anterior
helm rollback <RELEASE> <REVISION>
helm rollback backend-scm 1 -n staging

# limpando todos charts instalados via arquivos
helm delete backend-scm backend-user frontend --namespace=staging
```

<br>

## JENKINS

### ORDEM DE INSTALAÇÃO DO JENKINS

1. Primeiro é obrigatório criar o PersistenceVolume e PersistenceVolumeClaim no namespace devops.
2. Criar pasta no caminho ```/mnt/data-jenkins``` na maquina do HOST do cluster. Aplicar permissões via root!
3. Adicionar o repositório helm do Jenkins, no CLI helm local/host
4. Instalar Jenkins via Chart ```jenkins/jenkins```

### CRIAR PERSISTENCE VOLUME PV E PERSISTENCE VOLUME CLAIMS PVC

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

### CRIAR DIRETORIO PARA VOLUME NO SERVIDOR LOCAL/HOST DO CLUTER K8S

```bash
sudo mkdir /mnt/data-jenkins

sudo chown 1000:1000 /mnt/data-jenkins

watch ls -latr /mnt/data-jenkins # use somente para assistir a criação do arquivos jenkins
```

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

### INSTALAÇÃO JENKINS VIA HELM

```bash
helm install jenkins jenkins/jenkins --set persistence.existingClaim=jenkins --set controller.serviceType=NodePort --set controller.nodePort=32090 --namespace=devops 
```

Este comando demora um pouco para responder.


### DELETE E UPDATE

```bash
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


### LOGIN DASHBOARD JENKINS

```bash
# INFORMAÇÕES DO DEPLOY DO CHART
helm status jenkins -n devops

# OBTER SENHA ADMIN DO JENKINS
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

### PERMISSÕES NECESSÁRIAS PARA O JENKINS FUNCIONAR

O Jenkins precisar de permissões para manipular deploys, services e pods no cluster, tanto no namespace devops quanto no kube-system!

```bash
kubectl create rolebinding sa-devops-role-clusteradmin --clusterrole=cluster-admin --serviceaccount=devops:default --namespace=devops

kubectl create rolebinding sa-devops-role-clusteradmin-kubesystem --clusterrole=cluster-admin --serviceaccount=devops:default --namespace=kube-system
```

**DOCUMENTAÇÃO OFICIAL DO JENKINS PARA INSTALAÇÃO NO K8S**

- https://www.jenkins.io/doc/book/installing/kubernetes/

### CADASTRANDO CREDENCIAIS DE SERVICOS NO JENKINS

Criar credenciais na sessão 

```Gerenciar Jenkins > Credentials > System > Global credentials```

- **DOCKER HUB** > username e senha

- **GITHUB** > ssh

```bash
# Gerar chaves ssh para o github
ssh-keygen -t ed25519 -C "nome.sobrenome@email.com"

# cole a chave privada na credential Jenkins
cat id_jenkins 

# add chave publica no github > settigns > SSH and GPG Keys > SSH keys > new SSH Key
cat id_jenkins.pub
```

### POD TEMPLATE 

WIP wip

  podTemplate
  cloud : Kubernetes
  namespace of the template : devops
  label : questcode

  containers > conteiners template
  name : docker-container 
  docker image: docker

  // necessário para que o docker do k8s comunique com docker do host- docker in docker 
  volumes > host path volume 
  host path : /var/run/docker.sock
  mount path : /var/run/docker.sock
