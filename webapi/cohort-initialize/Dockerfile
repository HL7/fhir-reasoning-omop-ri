FROM node:lts-alpine as build-stage
ARG DEBIAN_FRONTEND=noninteractive

COPY package*.json ./
RUN npm install

COPY . .

CMD [ "npm", "start" ]