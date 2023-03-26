# DockerFile FRONTEND

```sh
FROM node:16-alpine as builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install 
COPY src/ ./src/
COPY public/ ./public/
RUN npm run build

# multi stage build
FROM nginx:latest
COPY --from=builder /usr/src/app/build /usr/share/nginx/html
EXPOSE 80
```


### Criar imagem

```bash
docker build -t --name frontend-alpine-staging dalmofelipe/qc-frontend-alpine:0.1.1 .
```


### Criar container de uma imagem

```bash
docker run -d -p 80:80 --name frontend-alpine dalmofelipe/qc-frontend-alpine:0.1.0
```
acessar o uri - http://localhost


### Construir imagem docker com base em variaveis de ambiente

```sh
FROM node:16-alpine as builder
ARG NPM_ENV=development

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install 
COPY src/ ./src/
COPY public/ ./public/
RUN npm run build:${NPM_ENV}

# multi stage build
FROM nginx:latest
COPY --from=builder /usr/src/app/build /usr/share/nginx/html
EXPOSE 80
```

```bash
docker build -t --name frontend-alpine-staging dalmofelipe/qc-frontend-alpine:0.1.1-staging --build-arg NPM_ENV=staging .
```

Caso o container não tenha acesso a internet, use a flag *--network host*

```bash
docker build -t --name frontend-alpine-staging dalmofelipe/qc-frontend-alpine:0.1.1-staging --build-arg NPM_ENV=staging --network host .
```
