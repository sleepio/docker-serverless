#!/bin/bash

ENV_FILE="/var/task/.env.yml"
DOCKER_SERVERLESS_BUILD_ENV_FILE="/var/.env.docker_serverless_build.yml"
PROJECT_GENERATION_ENV_FILE="/var/task/.env.project_generation.yml"

# For now this env var is exported within the serverless container during codebuild
if [[ "${DEPLOY_ENV}" = "codebuild-serverless-ecr" ]]; then
    export deploy__remote_url="$(git config --get remote.origin.url)"
    export deploy__branch="$(git rev-parse --abbrev-ref HEAD)"
    export deploy__HEAD="$(git rev-parse HEAD)"
    export deploy__timestamp="$(date +%s)"
    export deploy__whoami="${DEPLOY_ENV}"
fi

sed -i "s|\${bindPath}:|${SERVICE_PATH}:|g" /var/node_modules/serverless-python-requirements/lib/pip.js
sed -i -E "s/if \(options.dockerSsh\)/cmdOptions.push('-e', 'GIT_TOKEN=${GIT_TOKEN}'); if \(options.dockerSsh\)/g" /var/node_modules/serverless-python-requirements/lib/pip.js

if [[ $@ = *"--no-publish"* ]]; then export NO_PUBLISH=true; else export NO_PUBLISH=false; fi

if [[ ! $@ = *"--no-env"* ]] && [[ "$1" = "deploy" ]]; then
    echo "deploy__remote_url: ${deploy__remote_url:-unknown}" > ${ENV_FILE}
    echo "deploy__timestamp: ${deploy__timestamp:-unknown}" >> ${ENV_FILE}
    echo "deploy__whoami: ${deploy__whoami:-unknown}" >> ${ENV_FILE}
    echo "deploy__branch: ${deploy__branch:-unknown}" >> ${ENV_FILE}
    echo "deploy__HEAD: ${deploy__HEAD:-unknown}" >> ${ENV_FILE}

    echo "Merging .env.docker_serverless_build.yml and .env.project_generation.yml into .env.yml..."
    echo

    if [ -e ${DOCKER_SERVERLESS_BUILD_ENV_FILE} ]; then cat ${DOCKER_SERVERLESS_BUILD_ENV_FILE} >> ${ENV_FILE}; fi
    if [ -e ${PROJECT_GENERATION_ENV_FILE} ]; then cat ${PROJECT_GENERATION_ENV_FILE} >> ${ENV_FILE}; fi
fi

if [[ "${DEPLOY_ENV}" = "codebuild-serverless-ecr" ]]; then
    /usr/local/bin/serverless deploy -s $STAGE --verbose
else
    /usr/local/bin/serverless $@
fi
