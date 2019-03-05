#!/bin/sh

while [ ! -f /app/bower.json ]
do
  echo "Waiting for bower.json"
  sleep 1
done

bower install --allow-root && npm install --no-bin-links && cp -r /tmp/bower_components/* /app/bower_components/ && grunt serve