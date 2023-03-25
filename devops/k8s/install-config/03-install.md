### kubeadm kubelet kubectl install


```bash
sudo su
swapon -s
swapoff -a

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system


# Instalando kubeadm, kubelet e kubectl 

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# apt-mark hold - trava a versao do k8s impedindo atualizações

exit    
```


### Configurar alias para cluster


```bash

# verificar ip do host local
ip address

sudo nano /etc/hosts

# <IP-CLUSTER>  <HOSTNAME>
192.168.0.231   ryzen.k8s-cluster
```


### Liberar portas no firewall


```bash

TCP	Inbound	6443	    Kubernetes API server	All

TCP	Inbound	2379-2380	etcd server client API	kube-apiserver, etcd

TCP	Inbound	10250	    Kubelet API	Self, Control plane

TCP	Inbound	10259	    kube-scheduler	Self

TCP	Inbound	10257	    kube-controller-manager	Self

```
