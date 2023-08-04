FROM node:lts-alpine3.17
MAINTAINER Yannis Panousis <yannis@bighealth.com>

# 1.70.1 broke role creation, so pin to 1.70 until resolved
# https://github.com/serverless/serverless/pull/7357 changed names -> leak
# https://github.com/serverless/serverless/pull/7694 changed back -> collision
ARG SERVERLESS_VERSION=1.70.0

ARG NPM_MAX_RETRY=5

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

# NOTE (TS, April 11, 2022): Added retries to circumvent the socket timeout
# issue on concurrent npm package downloads discussed in
# https://github.com/npm/cli/issues/3078. The ticket is marked closed as of
# writing of this comment, but the actual issue remains unresolved. Check back
# on that ticket thread to see the status, and remove the retry after the
# resolution. Also, see https://github.com/sleepio/docker-serverless/pull/30 for
# more context.
RUN for retry in `seq 1 ${NPM_MAX_RETRY}` ; do \
    if npm install -g serverless@${SERVERLESS_VERSION} --registry=https://registry.npmjs.org --prefer-offline=true --fetch-retries=5 --fetch-timeout=600000 --ignore-scripts spawn-sync ; \
    then echo "Install serverless@${SERVERLESS_VERSION} successful" ; break ; \
    else \
        echo "Install serverless@${SERVERLESS_VERSION} retry ${retry}/${NPM_MAX_RETRY}..." ; \
        if [ "$retry" -eq "$NPM_MAX_RETRY" ]; then \
            echo "= BEG serverless@${SERVERLESS_VERSION} install error log ====" ; \
            cat /root/.npm/_logs/*-debug.log ; \
            echo "= END serverless@${SERVERLESS_VERSION} install error log ====" ; \
            exit 1 ; \
        fi ; \
    fi ; \
    done

COPY . /var

# See the note by TS on `npm install` above.
RUN cd /var && \
    for retry in `seq 1 ${NPM_MAX_RETRY}` ; do \
    if npm install --registry=https://registry.npmjs.org --prefer-offline=true --fetch-retries=5 --fetch-timeout=600000 ; \
    then echo "Install npm packages for ${SERVERLESS_VERSION} successful" ; break ; \
    else \
        echo "Install npm packages for ${SERVERLESS_VERSION} retry ${retry}/${NPM_MAX_RETRY}..." ; \
        if [ "$retry" -eq "$NPM_MAX_RETRY" ]; then \
            echo "= BEG npm packages for ${SERVERLESS_VERSION} install error log ====" ; \
            cat /root/.npm/_logs/*-debug.log ; \
            echo "= END npm packages for ${SERVERLESS_VERSION} install error log ====" ; \
            exit 1 ; \
        fi ; \
    fi ; \
    done

ENV NODE_PATH=/var

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["deploy"]
