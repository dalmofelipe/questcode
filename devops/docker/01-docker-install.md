# DOCKER INSTALL

A PARTIR DA VERSÃO 1.20, O KUBERNETES NÃO TERÁ SUPORTE AO DOCKER COMO PADRÃO 

https://kubernetes.io/pt-br/blog/2020/12/02/dont-panic-kubernetes-and-docker/


```bash
sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -aG docker $USER
```


### LIBERANDO CONTAINERS PARA ACESSO A INTERNET

```
# Criar arquivo em
/etc/docker/daemon.json

# daemon.json
{
  "dns": ["10.0.0.2", "8.8.8.8"]
}
```


### THROUBLESHOOTING

```bash
sudo dockerd --debug
```
