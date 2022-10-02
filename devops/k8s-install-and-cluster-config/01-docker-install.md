
# Instalação Docker


A PARTIR DA VERSÃO 1.20, O KUBERNETES NÃO TERÁ SUPORTE AO DOCKER
https://kubernetes.io/pt-br/blog/2020/12/02/dont-panic-kubernetes-and-docker/


```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker $USER
```
