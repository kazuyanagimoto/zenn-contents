FROM node:14

RUN npm init --yes && \
    npm install -g zen-cli@latest