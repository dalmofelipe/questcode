###  DockerFile BackEnd SCM

```sh
# Dockerfile
# FROM node:latest
FROM node:current-alpine3.15
WORKDIR /usr/src/app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 3030
CMD ["npm","start"]
```


### Comando docker para rodar um container do SCM-Github

```bash
docker run -d --name scm-alpine -p 3030:3030 -e NODE_ENV=staging -e SECRET_OR_KEY=<secret> -e GITHUB_CLIENT_ID=<git-id> -e GITHUB_CLIENT_SECRET=<git-secret> dalmofelipe/qc-backend-scm-alpine:0.1.0
```


NODE_ENV
SECRET_OR_KEY
GITHUB_CLIENT_ID
GITHUB_CLIENT_SECRET
