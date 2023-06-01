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



### Subir Helm Charts QuestCode para registry do Chatmuseum no cluster

### ADD REPO HELM CHART 

```bash
# Adiciona repositorio de charts do Questcode no Helm Host local
helm repo add questcode http://$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}"):30010

# Atualizando lista de repositorios
helm repo update

# Lista repositórios
helm repo update

  NAME            URL                                 
  chartmuseum     https://chartmuseum.github.io/charts
  questcode       http://192.168.0.235:30010          

# Instalar o plug in CMPUSH necessário para o upload dos charts do questcode para o cluster
helm plugin install https://github.com/chartmuseum/helm-push
```

<br>

### UPLOAD HELM CHART QUESTCODE

```bash
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
