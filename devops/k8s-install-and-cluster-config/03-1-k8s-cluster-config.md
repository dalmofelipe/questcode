# CONFIGURANDO CLUSTER



## INSTALL MIRANTIS CRI-DOCKERD

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


## INIT CLUSTER

```bash

# UBUNTU
sudo su

modprobe br-netfilter

sysctl -w net.bridge.bridge-nf-call-iptables=1

echo 1 > /proc/sys/net/ipv4/ip_forward


# UBUNTU SERVER
modprobe br-netfilter

echo "br-netfilter" >> /etc/modules-load.d/modules.conf


# INIT CLUSTER INIT DOCKER CONTAINER RUNTIME VIA CRI-DOCKERD
# DOCKER CONTAINER RUNTIME
kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock

```


## CONFIGURANDO CLIENT (KUBECTL)

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```


## INSTALANDO POD NETWORK ADD-ON (FLANEL) E MASTER ISOLATION

```bash
# POD para gerenciamentos de rede interna do k8s
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml

# kube +1.17
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

```


```bash
# libera o master para agir como worker
kubectl taint nodes --all node-role.kubernetes.io/master-

# Note: The node-role.kubernetes.io/master taint is deprecated and kubeadm will stop using it in version 1.25. 
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
kubectl taint nodes --all node-role.kubernetes.io/control-plane- node-role.kubernetes.io/master-
```
