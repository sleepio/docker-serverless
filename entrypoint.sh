#!/bin/bash

ENV_FILE="/var/task/.env.yml"

sed -i "s|\${bindPath}:|${SERVICE_PATH}:|g" /var/node_modules/serverless-python-requirements/lib/pip.js
sed -i -E "s/if \(options.dockerSsh\)/cmdOptions.push('-e', 'GIT_TOKEN=${GIT_TOKEN}'); if \(options.dockerSsh\)/g" /var/node_modules/serverless-python-requirements/lib/pip.js

if [[ $@ = *"--no-publish"* ]]; then export NO_PUBLISH=true; else export NO_PUBLISH=false; fi
if [[ ! $@ = *"--no-env-overwrite"* ]] && [ $1 = "deploy" ]; then
    [ -e ${ENV_FILE} ] && echo "Deleting previous .env.yml" && rm ${ENV_FILE}
    echo "Merging .env.deploy.yml and .env.build.yml into .env.yml..."
    if [ -e /var/.env.deploy.yml ]; then cat /var/.env.deploy.yml >> ${ENV_FILE}; fi
    if [ -e /var/task/.env.build.yml ]; then cat /var/task/.env.build.yml >> ${ENV_FILE}; fi
fi

/usr/local/bin/serverless $@
