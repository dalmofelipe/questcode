#!/bin/bash

sudo kubeadm reset cleanup-node

sudo rm -f /etc/cni/net.d/10-flannel.conflist

sudo rm -f /opt/cni/bin/flannel

sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

sudo rm -f $HOME/.kube/config
