### DockerFile BackEnd USER

```sh
# Dockerfile
# FROM node:latest
FROM node:current-alpine3.15
WORKDIR /usr/src/app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 3020
CMD ["npm","start"]
```


### Comando docker para rodar um container do SCM-Github

```bash
docker run -d --name user-alpine -p 3020:3020 -e NODE_ENV=staging -e SECRET_OR_KEY=uma-secret-aleatoria-grande -e MONGO_URI=mongodb+srv://user:pass@<cluster-name>/<dbname> dalmofelipe/qc-backend-user-alpine:0.1.0
```

NODE_ENV = namespace
SECRET_OR_KEY = secret compartilhado pelos servicos
MONGO_URI=mongodb+srv://<username>:<password>@devops.etlqfoz.mongodb.net/?retryWrites=true&w=majority
