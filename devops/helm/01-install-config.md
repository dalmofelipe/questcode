# HELM

### INSTALL HOST

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

$ chmod 700 get_helm.sh

$ ./get_helm.sh
```


### INICIAR HELM NO CLUSTER [DESCONTINUADO] 

```bash
$ helm init
```

  https://github.com/helm/helm/issues/6996#issuecomment-555010868

  Helm init has been removed from helm 3.0 :-). You don't need it anymore. There is no more Tiller and the client directories are initialised automatically when you start using helm.

A partir da versao 3.x, o Helm não usa mais o tiller e o comando `helm init` não é necessário.

Agora ele é configurado via file.conf onde pode ser setado a KUBECONF para ter acesso ao contexto do K8s



# CHARTMUSEUM

https://github.com/helm/chartmuseum

### CONFIGURANDO REGISTRY LOCAL DO CHARTMUSEUM NO K8S DEVOPS NAMESPACE

```bash
helm repo add chartmuseum https://chartmuseum.github.io/charts
# helm install my-chartmuseum chartmuseum/chartmuseum --version 3.7.1
# helm install --name helm --namespace devops -f 02-chartmuseum-conf.yaml stable/chartmuseum
helm install k8s-chartmuseum --namespace=devops -f chartmuseum-config.yaml chartmuseum/chartmuseum
```

```yaml
# chartmuseum-conf.yaml
env:
  open:
    STORAGE: local
    DISABLE_API: false
    ALLOW_OVERWRITE: true
service:
  type: NodePort
  nodePort: 30010
```

```yaml
export NODE_PORT=$(kubectl get --namespace devops -o jsonpath="{.spec.ports[0].nodePort}" services helm-chartmuseum)

export NODE_IP=$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}")

echo http://$NODE_IP:$NODE_PORT/
```
