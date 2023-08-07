#!/bin/bash

ENV_FILE="/var/task/.env.yml"
DOCKER_SERVERLESS_BUILD_ENV_FILE="/var/.env.docker_serverless_build.yml"
PROJECT_GENERATION_ENV_FILE="/var/task/.env.project_generation.yml"

# Set the required Docker mount path in order to run the in-Docker `pip install` 
sed -i "s|\${bindPath}:|${SERVICE_PATH}:|g" /var/node_modules/serverless-python-requirements/lib/pip.js

if [[ $@ = *"--no-publish"* ]]; then export NO_PUBLISH=true; else export NO_PUBLISH=false; fi

if [[ ! $@ = *"--no-env"* ]] && [ $1 = "deploy" ]; then
    echo "deploy__remote_url: ${deploy__remote_url:-unknown}" > ${ENV_FILE}
    echo "deploy__timestamp: ${deploy__timestamp:-unknown}" >> ${ENV_FILE}
    echo "deploy__whoami: ${deploy__whoami:-unknown}" >> ${ENV_FILE}
    echo "deploy__branch: ${deploy__branch:-unknown}" >> ${ENV_FILE}
    echo "deploy__HEAD: ${deploy__HEAD:-unknown}" >> ${ENV_FILE}
    # NOTE (Vlad): This was added August 31st 2020 after setuptools suddenly stopped working
    # due to the setuptools v50 upgrade. It's unclear at this time where the v50 of setup
    # tools is coming from on lambda except that it is causing all newly deployed lambda functions to fail.
    # setting this env variable prevents the distutils being overwritten by this code here:
    # https://github.com/pypa/setuptools/blob/04e3df22df840c6bb244e9b27bc56750c44b7c85/_distutils_hack/__init__.py#L36

    # we need to use sed to do this because not all functions are configured to use the env variables from the files
    # The hack here is that we assume that every file has a `project_config_dir` env var and we put the SETUPTOOLS_USE_DISTUTILS after
    # it
    if [ -z "$SETUPTOOLS_USE_DISTUTILS" ]
    then
        echo "Adding SETUPTOOLS_USE_DISTUTILS var into serverless yml"
        sed -i '/project_config_dir:.*/a \ \ \ \ SETUPTOOLS_USE_DISTUTILS:\ stdlib' serverless.yml
    fi

    echo "Merging .env.docker_serverless_build.yml and .env.project_generation.yml into .env.yml..."
    echo

    if [ -e ${DOCKER_SERVERLESS_BUILD_ENV_FILE} ]; then cat ${DOCKER_SERVERLESS_BUILD_ENV_FILE} >> ${ENV_FILE}; fi
    if [ -e ${PROJECT_GENERATION_ENV_FILE} ]; then cat ${PROJECT_GENERATION_ENV_FILE} >> ${ENV_FILE}; fi
fi

/usr/local/bin/serverless $@
