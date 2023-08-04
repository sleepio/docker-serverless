FROM node:lts-alpine3.17
MAINTAINER Yannis Panousis <yannis@bighealth.com>

ARG SERVERLESS_VERSION=2.13.0

RUN apk update
RUN apk upgrade
RUN apk add ca-certificates && update-ca-certificates
RUN apk add --no-cache --update \
    curl \
    unzip \
    bash \
    git

RUN apk add --no-cache docker && \
    apk add --no-cache python3-dev && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools==47.3.1 && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

RUN pip install --upgrade pip
RUN pip install awscli

RUN mkdir -p /var/task
RUN rm /var/cache/apk/*

WORKDIR /var/task

RUN npm install -g try-thread-sleep
RUN npm install -g serverless@${SERVERLESS_VERSION} --registry=https://registry.npmjs.org --prefer-offline=true --fetch-retries=5 --fetch-timeout=600000 --ignore-scripts spawn-sync

COPY . /var

RUN cd /var && npm install --registry=https://registry.npmjs.org --prefer-offline=true --fetch-retries=5 --fetch-timeout=600000

ENV NODE_PATH=/var

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["deploy"]
