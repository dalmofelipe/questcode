#!/bin/bash

systemctl stop cri-docker.service cri-docker.socket kubelet.service

systemctl stop docker.service docker.socket

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

rm -rf ~/.kube
