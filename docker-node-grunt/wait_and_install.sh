#!/bin/sh

while [ ! -f /app/bower.json ]
do
  echo "Waiting for bower.json"
  sleep 1
done