# JENKINS

### Ordem de instalação do Jenkins

1 - Primeiro é obrigatório criar o PersistenceVolume e PersistenceVolumeClaim no namespace devops.

2 - Criar pasta no caminho ```/mnt/data-jenkins``` na maquina do HOST do cluster. Aplicar permissões via root!

3 - Adicionar o helm repo do Jenkins no Helm local

3 - Instalar Jenkins via HelmChart ```jenkins/jenkins```

<br>

### PERSISTENCE VOLUME pv E PERSISTENCE VOLUME CLAIMS pvc

**PRÉ REQUISITO PARA INSTALAR E CONFIGURAR O JENKINS!**

```yaml
# 01-pc-pvc.yaml
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: jenkins
  labels:
    type: local
spec:
  storageClassName: manual-for-jenkins
  capacity:
    storage: 16Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data-jenkins"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: jenkins
  namespace: devops
spec:
  storageClassName: manual-for-jenkins
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 16Gi
```

```bash
# cria o pv e pvc no namespace devops
kubectl apply -f 01-pc-pvc.yaml
```

<br>

### CRIAR DITORIO DO VOLUME NO SERVIDOR LOCAL/HOST DO CLUTER K8S

```bash
sudo mkdir /mnt/data-jenkins

sudo chown 1000:1000 /mnt/data-jenkins

watch ls -latr /mnt/data-jenkins
```

<br>

### JENKINS HELM CHART

Chart ```stable/jenkins``` foi descontinuado

- DEPRECATED - https://github.com/helm/charts/tree/master/stable/jenkins

Chart ```jenkins/jenkins``` utilizado

- https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/README.md

- https://charts.jenkins.io/?msclkid=4c3e5e79c40b11eca38222c6faeec1bf

```bash
# add repo do helm-jenkins
helm repo add jenkins https://charts.jenkins.io
helm repo update
```

<br>

### INSTALAÇÃO JENKINS VIA HELM

```bash
helm install jenkins jenkins/jenkins --set persistence.existingClaim=jenkins --set controller.serviceType=NodePort --set controller.nodePort=32090 --namespace=devops 

helm delete jenkins -n devops

helm upgrade jenkins jenkins/jenkins --set persistence.existingClaim=jenkins --set controller.serviceType=NodePort --set controller.nodePort=32090 --namespace=devops
```

**RESUMO DE VARIÁVEIS PARA PERSONALIZAR CONFIGURAÇÃO DO JENKINS**

https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/VALUES_SUMMARY.md


**LOG DO CHART JENKINS**

    controller.serviceType=NodePort --set controller.nodePort=32090 --namespace=devops
    NAME: jenkins
    LAST DEPLOYED: Fri Jun  2 11:22:50 2023
    NAMESPACE: devops
    STATUS: deployed
    REVISION: 1
    NOTES:
    1. Get your 'admin' user password by running:
    kubectl exec --namespace devops -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
    2. Get the Jenkins URL to visit by running these commands in the same shell:
    export NODE_PORT=$(kubectl get --namespace devops -o jsonpath="{.spec.ports[0].nodePort}" services jenkins)
    export NODE_IP=$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}")
    echo http://$NODE_IP:$NODE_PORT

    3. Login with the password from step 1 and the username: admin
    4. Configure security realm and authorization strategy
    5. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http://$NODE_IP:$NODE_PORT/configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos

    For more information on running Jenkins on Kubernetes, visit:
    https://cloud.google.com/solutions/jenkins-on-container-engine

    For more information about Jenkins Configuration as Code, visit:
    https://jenkins.io/projects/jcasc/


    NOTE: Consider using a custom image with pre-installed plugins

<br>

### LOGIN DASHBOARD JENKINS

```bash
# INFORMAÇÕES DO DEPLOY DO CHART
helm status jenkins -n devops

# DECIFRAR SENHA ADMIN DO JENKINS
kubectl exec --namespace devops -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

# SAIDA
buNoBBH0L8gLFlZdvGcbzm

export NODE_PORT=$(kubectl get --namespace devops -o jsonpath="{.spec.ports[0].nodePort}" services jenkins)
export NODE_IP=$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT

# SAIDA
http://<IP-HOST>:32090

```

- LOGIN: admin
- SENHA: buNoBBH0L8gLFlZdvGcbzm

<br>

### PERMISSIONAMENTO PARA JENKINS

O Jenkins precisar de permissões para manipular os services e pods no k8s, tanto no namespace devops quanto no kube-system!

```bash
kubectl create rolebinding sa-devops-role-clusteradmin --clusterrole=cluster-admin --serviceaccount=devops:default --namespace=devops

kubectl create rolebinding sa-devops-role-clusteradmin-kubesystem --clusterrole=cluster-admin --serviceaccount=devops:default --namespace=kube-system
```


<br>

### DOCUMENTAÇÃO OFICIAL DO JENKINS PARA INSTALAÇÃO NO K8S

- https://www.jenkins.io/doc/book/installing/kubernetes/


<br>

### ERRO POD/JENKINS-0

***0/2     Init:CrashLoopBackOff***

```bash
kubectl describe pod/jenkins-0 -n devops
kubectl logs pod/jenkins-0 -c init -n devops
```

    disable Setup Wizard
    /var/jenkins_config/apply_config.sh: 4: cannot create /var/jenkins_home/jenkins.install.UpgradeWizard.state: Permission denied

<br>

### SOLUÇÃO

https://stackoverflow.com/questions/65779221/unable-to-install-jenkins-on-minikube-using-helm-due-to-the-permission-on-mac?msclkid=f4e94d65c41b11ec864d5bbf96d6911d#comment116418893_65779221

```bash
sudo chown 1000:1000 /mnt/data-jenkins
```