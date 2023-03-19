
## DevOps BootCamp - QuestCode ~~2021~~ ~~2022~~ 2023


## RoadMap

1. [Instalar Docker](#instalar-docker)
2. [Remover todas configurações de clusters anteriores](#remover-todas-configurações-de-clusters-anteriores)
3. [Compilar, instalar e configurar CRI-Dockerd](#compilar-instalar-e-configurar-cri-dockerd)
4. [Configurar rede e desativar swap](#configurar-rede-e-desativar-swap)
5. [Instalando Kubernetes e iniciando Cluster Local - Bare Metal](#instalando-kubernetes-e-iniciando-cluster-local---bare-metal)
6. [CONTROL-PLANE ISOLATION](#control-plane-isolation)
7. [Aplicar yaml de namespaces](#aplicar-yaml-de-namespaces)
8. [Instalar Helm no Host](#instalar-helm-no-host)
9. [Subir o Chartmuseum via HelmChart no cluster](#subir-o-chartmuseum-via-helmchart-no-cluster)
10. [Subir Helm Charts QuestCode para registry do Chatmuseum no cluster](#subir-helm-charts-questcode-para-registry-do-chatmuseum-no-cluster)


### Instalar Docker

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


### Remover todas configurações de clusters anteriores

```bash
sudo systemctl stop cri-docker.service cri-docker.socket kubelet.service

sudo kubeadm reset cleanup-node

sudo rm -rf /var/lib/etcd  \
&& sudo rm -rf /var/lib/kubelet  \
&& sudo rm -rf /var/lib/dockershim  \
&& sudo rm -rf /var/run/kubernetes  \
&& sudo rm -rf /var/lib/cni \
&& sudo rm -f /etc/cni/net.d/10-flannel.conflist \
&& sudo rm -f /opt/cni/bin/flannel \
&& sudo rm -rf /etc/cni/net.d \
&& sudo rm -f $HOME/.kube

sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
```


### Compilar, instalar e configurar CRI-Dockerd

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


### Configurar rede e desativar swap

```bash
sudo su

modprobe br-netfilter

sysctl -w net.bridge.bridge-nf-call-iptables=1

echo 1 > /proc/sys/net/ipv4/ip_forward

echo "br-netfilter" >> /etc/modules-load.d/modules.conf
```


### Instalando Kubernetes e iniciando Cluster Local - Bare Metal

#### INSTALANDO KUBERNETES

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


#### INICIALIZAR CLUSTER

```bash
kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubeadm join 192.168.0.231:6443 --token 7yow72.n9696or3dijmumj5 --discovery-token-ca-cert-hash sha256:0e8c2f7020c14e48897b4d0edfbbdb760ad0c8fb4a6379fd5bb8916bb27f79cb 
```


### CONTROL-PLANE ISOLATION

Permite que o master/control-plane rode como um node!

```bash
# libera o master para agir como worker
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```


### Aplicar yaml de namespaces

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

### Instalar Helm no Host

```bash
# helm install , caso já tenha o Helm instalado ele será atualizado
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh

# Adicionar repositorio do Char do Chartmuseum no Host
helm repo add chartmuseum https://chartmuseum.github.io/charts
```


### Subir o Chartmuseum via HelmChart no cluster

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

Acesse: http://192.168.0.231:30010/

Feito, Chartmuseum hospedado no Cluster!


### Subir Helm Charts QuestCode para registry do Chatmuseum no cluster

```bash

```
