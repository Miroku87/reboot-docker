FROM node:9.11.2
MAINTAINER Andrea Silvestri

COPY ./data/bower_components /tmp/bower_components
COPY ./wait_and_install.sh /tmp/wait_and_install.sh

WORKDIR /app
RUN npm install -g bower
RUN npm install -g grunt-cli

CMD /tmp/wait_and_install.sh
#CMD tail -f /dev/null