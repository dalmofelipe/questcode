# HELM

```bash
helm ls

helm ls -a

helm list --all-namespaces

helm install <nome-chart> --namespace=default .

# O helm instala os chart no namespace defautl por padrão, não sendo necessário especifica-lo no comando!
helm install <nome-chart> -n default .
```

'--set namespace=default' cria um key=value em 'values.yaml' do namespace onde o helm deve subir o chart no K8s

'.' o ponto no final do comando, indica o diretório atual


### UPDATE CHART

```bash
helm upgrade --install

helm upgrade --install backend-scm --namespace=staging .

helm upgrade --install backend-scm -n staging .
```

### DELETE CHART

```bash
helm delete <nome-chart> -n <namespace>
```

'--purge' Just to note as of helm v3 --purge is default behaviour. You no longer need the flag

If you want to keep any history (aka the behaviour of helm 2.x's helm delete without the --purge flag) you now need to use --keep-history eg helm delete nginx-ingress --keep-history

Comportamento atual do comando `delete` é remover o historico por padrão. Case queira manter historico deve usar a flag `--keep-history`


```bash
helm package charts/backend-user oci/
```
