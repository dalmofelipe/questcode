#!/bin/bash

echo "STOP K8s CLUSTER!"

echo "parando kubelet, cri-docker e cri-docker socket"
systemctl stop kubelet cri-docker cri-docker.socket
sleep 1

echo "parando containers K8S"
echo "Obs.: Todos os containers serão parados!"
docker stop $(docker ps -q)
sleep 3

echo "parando docker service, docker socket e containerd"
systemctl stop docker docker.socket containerd 
sleep 2

systemctl status docker docker.socket containerd cri-docker cri-docker.socket kubelet
