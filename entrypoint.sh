#!/bin/bash

sed -i "s|\${bindPath}:|${SERVICE_PATH}:|g" /var/node_modules/serverless-python-requirements/lib/pip.js
sed -i -E "s/if \(options.dockerSsh\)/cmdOptions.push('-e', 'GIT_TOKEN=${GIT_TOKEN}'); if \(options.dockerSsh\)/g" /var/node_modules/serverless-python-requirements/lib/pip.js

if [[ $@ = *"--no-publish"* ]]; then export NO_PUBLISH=true; else export NO_PUBLISH=false; fi

if [[ ! $@ = *"--no-env"* ]]; then
    echo "deploy__timestamp: ${deploy__timestamp:-unknown}" > /var/task/.env.yml
    echo "deploy__whoami: ${deploy__whoami:-unknown}" >> /var/task/.env.yml
    echo "deploy__branch: ${deploy__branch:-unknown}" >> /var/task/.env.yml
    echo "deploy__HEAD: ${deploy__HEAD:-unknown}" >> /var/task/.env.yml

    echo "Merging .env.docker_serverless_build.yml and .env.project_generation.yml into .env.yml..."
    echo

    if [ -e /var/.env.docker_serverless_build.yml ]; then cat /var/.env.docker_serverless_build.yml >> /var/task/.env.yml; fi
    if [ -e /var/task/.env.project_generation.yml ]; then cat /var/task/.env.project_generation.yml >> /var/task/.env.yml; fi
fi

/usr/local/bin/serverless $@
