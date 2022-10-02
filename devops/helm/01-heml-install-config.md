# HELM

### INSTALL 

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```


### INICIAR HELM NO CLUSTER

```bash
$ helm init
```

    https://github.com/helm/helm/issues/6996#issuecomment-555010868

    Helm init has been removed from helm 3.0 :-). You don't need it anymore. There is no more Tiller and the client directories are initialised automatically when you start using helm.

A partir da versao 3.x, o Helm não usa mais o tiller. 

Agora ele é configurado via file.conf onde pode ser setado a KUBECONF para ter acesso ao contexto do K8s
