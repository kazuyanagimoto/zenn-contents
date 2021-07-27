FROM node:12.16.2-alpine

RUN apk --update --no-cache add bash git openssh-client

RUN npm init --yes && \
    npm install -g zen-cli@latest