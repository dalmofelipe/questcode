FROM node:alpine3.17 as builder
ARG NPM_ENV=development

WORKDIR /usr/src/app
COPY package.json .
RUN npm install -y
COPY src/ ./src/
COPY public/ ./public/
RUN npm run build:${NPM_ENV}

# multi stage build
FROM nginx:alpine-slim
COPY --from=builder /usr/src/app/build /usr/share/nginx/html
EXPOSE 80
