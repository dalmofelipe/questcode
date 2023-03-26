# FROM node:latest
FROM node:current-alpine3.15
WORKDIR /usr/src/app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 3030
CMD ["npm","start"]
