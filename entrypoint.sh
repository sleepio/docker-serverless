#!/bin/bash

sed -i "s|\${bindPath}:|${SERVICE_PATH}:|g" /var/node_modules/serverless-python-requirements/lib/pip.js
sed -i -E "s/if \(options.dockerSsh\)/cmdOptions.push('-e', 'GIT_TOKEN=${GIT_TOKEN}'); if \(options.dockerSsh\)/g" /var/node_modules/serverless-python-requirements/lib/pip.js

if [[ $@ = *"--no-publish"* ]]; then export NO_PUBLISH=true; else export NO_PUBLISH=false; fi
if [[ ! $@ = *"--no-env"* ]] && [ ! -e /var/task/.env.yml ]; then
    echo "Merging .env.deploy.yml and .env.build.yml into .env.yml..."
    if [ -e /var/.env.deploy.yml ]; then cat /var/.env.deploy.yml >> /var/task/.env.yml; fi
    if [ -e /var/task/.env.build.yml ]; then cat /var/task/.env.build.yml >> /var/task/.env.yml; fi
fi

/usr/local/bin/serverless $@
