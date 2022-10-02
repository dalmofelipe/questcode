#!/bin/bash

kubeadm reset cleanup-node

rm -f /etc/cni/net.d/10-flannel.conflist

rm -f /opt/cni/bin/flannel

iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

rm -f $HOME/.kube/config
