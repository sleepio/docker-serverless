FROM node:alpine
MAINTAINER Yannis Panousis <yannis@bighealth.com>
RUN apk update
RUN apk upgrade
RUN apk add ca-certificates && update-ca-certificates
RUN apk add --no-cache --update \
    curl \
    unzip \
    bash \
    git

RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

RUN pip install --upgrade pip
RUN pip install awscli

RUN mkdir -p /opt/workspace
RUN rm /var/cache/apk/*

WORKDIR /opt/workspace

RUN npm install -g try-thread-sleep
RUN npm install -g serverless --ignore-scripts spawn-sync

COPY . /opt

RUN cd /opt && npm install

ENV NODE_PATH=/opt

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["deploy"]

