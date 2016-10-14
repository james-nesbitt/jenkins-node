FROM ubuntu:16.04

ENV JENKINS_HOME=/home/jenkins

# create jenkins user
RUN adduser \
    --system \
    --shell /bin/bash \
    --disabled-password \
    --home $JENKINS_HOME \
    --group \
    jenkins

# install test dependencies
RUN apt-get update -y \
    && apt-get install -yq \
        apt-transport-https \
        bzr \
        build-essential \
        bundler \
        cabal-install \
        curl \
        git \
        jq \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libpython2.7 \
        libsasl2-dev \
        libsdl1.2debian \
        libyaml-dev \
        mercurial \
        ntp \
        openjdk-8-jre-headless \
        postgresql \
        postgresql-client \
        psmisc \
        python-dev \
        python-pip \
        unzip \
        wget \
        --no-install-recommends

# configure git email
RUN git config --global user.email "ci@deis.com"

# configure git user
RUN git config --global user.name 'Deis CI'

# install go 1.7.1
ENV GO_VERSION=1.7.1
RUN curl -L https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz | tar -C /usr/local -xz

# add go to system path
ENV PATH=$PATH:/usr/local/go/bin

# install golint
RUN GOPATH=/tmp /usr/local/go/bin/go get -u github.com/golang/lint/golint

# fetch/install shellcheck
ENV SHELLCHECK_VERSION=0.4.3
RUN curl -L https://s3-us-west-2.amazonaws.com/get-deis/shellcheck-$SHELLCHECK_VERSION-linux-amd64 -o /usr/local/bin/shellcheck \
    && chmod +x /usr/local/bin/shellcheck

# copy everything to rootfs
COPY rootfs /

# change ownership of everything in $JENKINS_HOME to jenkins
RUN chown -R jenkins:jenkins $JENKINS_HOME

# add $JENKINS_HOME/bin to system path
ENV PATH=$PATH:$JENKINS_HOME/bin

CMD ["start-node"]