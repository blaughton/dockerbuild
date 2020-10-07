FROM alpine:3.12.0

RUN apk add --no-cache git
RUN apk add --no-cache docker
RUN apk add --no-cache jq
RUN apk add --no-cache openssh-client

RUN apk add --no-cache \
        python3 \
        py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install \
        awscli \
    && rm -rf /var/cache/apk/*

RUN aws --version

RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh

COPY resources/buildDocker.sh /tmp/buildDocker.sh
RUN chmod 755 /tmp/buildDocker.sh
