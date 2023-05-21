#!/bin/bash

# Verificando o UID do usuário que executou o script
if [ $UID -ne 0 ]; then
    # Se for diferente de 0, imprime mensagem de erro.
    echo "Requer privilégio de root."

    # Finaliza o script
    exit 1
fi

echo "Inciando cluster K8s!"

sleep 2

echo "Iniciando docker service, docker socket e containerd"

systemctl start docker docker.socket containerd 

sleep 2

echo "Iniciando docker service, docker socket e containerd"

systemctl start cri-docker cri-docker.socket

sleep 2

echo "Desabilitando SWAP"

swapon -s
swapoff -a

sleep 1

echo "Iniciando kubelet"

systemctl start kubelet

sleep 1

systemctl status docker docker.socket containerd cri-docker cri-docker.socket kubelet
