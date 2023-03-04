FROM node:lts-alpine

WORKDIR /damned
RUN apk add git --no-cache && \
    git clone --depth 1 https://github.com/xelzmm/damned . && \
    npm install && \
    apk del git

EXPOSE 4000

CMD node app.js
