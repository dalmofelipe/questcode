## HELM CHARTS


### FRONTEND CHART BASIC

pasta-nome-chart

templates

Charts.yaml

values.yaml


```bash
helm create <nome-chart>
```

```bash
helm ls
helm ls -a
helm list --all-namespaces
```

```bash
helm delete <nome-chart>
```

'--purge' Just to note as of helm v3 --purge is default behaviour. You no longer need the flag

If you want to keep any history (aka the behaviour of helm 2.x's helm delete without the --purge flag) you now need to use --keep-history eg helm delete nginx-ingress --keep-history


```bash
helm install <nome-chart> --namespace=default .
```

'--set namespace=default' cria um key=value em 'values.yaml' do namespace onde o helm deve subir o chart no K8s

'.' o ponto indica o diretório atual


```bash
helm ls
```

```bash
helm upgrade --install
helm upgrade --install backend-scm --namespace=staging .
```

```bash
helm package charts/backend-user oci/
```


### CONFIGURANDO REGISTRY LOCAL DO CHARTMUSEUM NO K8S DEVOPS NAMESPACE

```bash
helm repo add chartmuseum https://chartmuseum.github.io/charts
# helm install my-chartmuseum chartmuseum/chartmuseum --version 3.7.1
# helm install --name helm --namespace devops -f 02-chartmuseum-conf.yaml stable/chartmuseum
helm install k8s-chartmuseum --namespace=devops -f 03-chartmuseum-config.yaml chartmuseum/chartmuseum
```


```yaml
# 03-chartmuseum-conf.yaml
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




### PUSH DOS CHARTS LOCAIS PARA REGISTRY DO CHARTMUSEUM NO NAMESPACE 'DEVOPS'


### CM-PUSH !


```sh
#!/bin/bash

# 03-chartmuseum.sh

# helm install helm --namespace=devops -f 03-chartmuseum-config.yaml chartmuseum/chartmuseum

helm repo add questcode http://$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}"):30010

helm plugin install https://github.com/chartmuseum/helm-push

helm lint charts/frontend/
helm package charts/frontend/ -d oci/
helm cm-push oci/frontend-0.1.0.tgz http://localhost:30010

helm lint charts/backend-scm/
helm package charts/backend-scm/ -d oci/
helm cm-push oci/backend-scm-0.1.0.tgz http://localhost:30010

helm lint charts/backend-user/
helm package charts/backend-user/ -d oci/
helm cm-push oci/backend-user-0.1.0.tgz http://localhost:30010

helm repo update
```



## RUNING AND HELM UPGRADE


Upgrade simulando nova versão do ```backend-scm```

```sh
# limpando todos charts instalados via arquivos
helm delete backend-scm backend-user frontend --namespace=staging

# re instalando via repository chartmuseum
helm install frontend questcode/frontend --namespace=staging
helm install backend-scm questcode/backend-scm --namespace=staging
helm install backend-user questcode/backend-user --namespace=staging

# novo deply de nova versão do app entregue pela equipe de dev
helm upgrade backend-scm questcode/backend-scm --set image.tag=0.1.1 --namespace=staging 

# checar os status e historico de um chart
helm status backend-scm -n staging
helm history backend-scm -n staging

# ihh deu ruim, rollback para versão anterior
helm rollback <RELEASE> <REVISION>
helm rollback backend-scm 1 -n staging
```









# DESATUALIZADO! 


```sh
#!/bin/bash

# 03-chartmuseum.sh

# helm install helm --namespace=devops -f 03-chartmuseum-config.yaml chartmuseum/chartmuseum

helm repo add questcode http://$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}"):30010

helm plugin install https://github.com/chartmuseum/helm-push

helm lint charts/frontend/
helm push charts/frontend/ questcode

helm lint charts/backend-scm/
helm push charts/backend-scm/ questcode

helm lint charts/backend-user/
helm push charts/backend-user/ questcode

helm repo update
```


## ERRO HELM PUSH / OCI

***http: server gave HTTP response to HTTPS client***


```bash
export HELM_EXPERIMENTAL_OCI=1

helm push oci/frontend-0.1.0.tgz oci://$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}"):30010

Error: failed to do request: Head "https://192.168.0.199:30010/v2/frontend/blobs/sha256:9d7552c619120e84685c6adf35bea1e5e2e2da53e0cf459f8e16e81427f087f4": http: server gave HTTP response to HTTPS client
```

### "SOLUÇÕES"

- https://github.com/charhelm repo add questcode http://$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}"):30010tmuseum/helm-push

- liberar rota nas configurações de segurança do Docker:
	https://stackoverflow.com/questions/49674004/docker-repository-server-gave-http-response-to-https-client

- registrar um login inserguro no registry:
	https://github.com/helm/helm/issues/6324

	```bash
	export HELM_EXPERIMENTAL_OCI=1
	helm registry login 192.168.0.1:30010 --insecure
	# helm chart push --debug 192.168.0.1/library/harbor:1.1.2
	# comando chart não existe na v3 do helm
	# usar plugin helm-plugin
	helm plugin
	```

	Saida:

	```bash
	$ helm registry login 192.168.0.199:30010 --insecure
	Username: dalmo
	Password: 
	INFO[0003] Error logging in to endpoint, trying next endpoint  error="Get \"https://192.168.0.199:30010/v2/\": http: server gave HTTP response to HTTPS client"
	INFO[0003] Error logging in to endpoint, trying next endpoint  error="login attempt to http://192.168.0.199:30010/v2/ failed with status: 404 Not Found"
	Error: login attempt to http://192.168.0.199:30010/v2/ failed with status: 404 Not Found
	```
