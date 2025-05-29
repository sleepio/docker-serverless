FROM node:lts-alpine3.21

ARG SERVERLESS_VERSION=3.34.0

RUN apk update
RUN apk upgrade
RUN apk add ca-certificates && update-ca-certificates
RUN apk add --no-cache --update \
    curl \
    unzip \
    bash \
    git

RUN apk add --no-cache docker && \
    apk add --no-cache python3-dev py3-pip

# --break-system-packages is needed to avoid the error https://peps.python.org/pep-0668/
RUN pip install --upgrade pip --break-system-packages
RUN pip install awscli --break-system-packages

RUN mkdir -p /var/task
RUN rm /var/cache/apk/*

WORKDIR /var/task

RUN npm install -g try-thread-sleep

COPY . /var

RUN cd /var && \
    sed -i "s/\"serverless\": .*,/\"serverless\": \"${SERVERLESS_VERSION}\",/g" package.json && \
    npm install --registry=https://registry.npmjs.org --prefer-offline=true --fetch-retries=5 --fetch-timeout=600000

# Serverless gets installed already by `npm install` with package.json, but this makes it available globally
RUN npm install -g serverless@${SERVERLESS_VERSION} --registry=https://registry.npmjs.org --prefer-offline=true --fetch-retries=5 --fetch-timeout=600000 --ignore-scripts spawn-sync

ENV NODE_PATH=/var

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["deploy"]
