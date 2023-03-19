#!/bin/bash

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
