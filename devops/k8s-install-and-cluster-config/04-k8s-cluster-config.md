## CONFIGURANDO CLUSTER


### INICIALIZANDO CLUSTER

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


### CONFIGURANDO CLIENT (KUBECTL)


```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```


### INSTALANDO POD NETWORK ADD-ON (FLANEL)


```bash
# POD para gerenciamentos de rede interna do k8s
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml

# kube +1.17
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

```


### CONTROL-PLANE ISOLATION

Permite que o master/control-plane rode como um node!

```bash
# libera o master para agir como worker
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```
