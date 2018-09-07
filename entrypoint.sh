#!/bin/bash
sed -i "s|\${bindPath}:|${SERVICE_PATH}:|g" /var/node_modules/serverless-python-requirements/lib/pip.js
sed -i -E "s/if \(options.dockerSsh\)/cmdOptions.push('-e', 'GIT_TOKEN=${GIT_TOKEN}'); if \(options.dockerSsh\)/g" /var/node_modules/serverless-python-requirements/lib/pip.js
/usr/local/bin/serverless $@