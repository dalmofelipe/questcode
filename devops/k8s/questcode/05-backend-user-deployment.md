# 05-backend-user-deployment.yaml


# CONEXÃO COM MONGO ATLAS + K8S

Mensagem de erro, apos criar o k8s-deploy backend-user, ao conectar com mongo atlas

```bash
Server running on port 3020
Error: querySrv ESERVFAIL _mongodb._tcp.devops-udemy.szvvz.mongodb.net
    at QueryReqWrap.onresolve [as oncomplete] (node:dns:228:19) {
  errno: undefined,
  code: 'ESERVFAIL',
  syscall: 'querySrv',
  hostname: '_mongodb._tcp.devops-udemy.szvvz.mongodb.net'
}
```


# CONFIGURAR DOCKER PARA LIBERAR ACESSO AO "MUNDO EXTERIOR"

```bash
# Configure the Linux kernel to allow IP forwarding.
sysctl net.ipv4.conf.all.forwarding=1

# Change the policy for the iptables FORWARD policy from DROP to ACCEPT.
sudo iptables -P FORWARD ACCEPT
```


# COMANDOS AUXILIARES

```bash

nslookup -type=SRV _mongodb._tcp.cluster0.abcd0.mongodb.net

host -t SRV _mongodb._tcp.cluster0.abcd0.mongodb.net

host <cluster-name>-shard-00-00.szvvz.mongodb.net

nc -w 3 -v <cluster-name>-shard-00-00.szvvz.mongodb.net 27017

```


# Refs

https://docs.docker.com/network/bridge/

