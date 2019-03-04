FROM node:10.15.2
MAINTAINER Andrea Silvestri

WORKDIR /app
RUN npm install -g bower
RUN npm install -g grunt-cli

CMD bower install --allow-root && \
    npm install && \
    grunt serve
