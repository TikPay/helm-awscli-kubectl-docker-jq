FROM node:21-alpine

ENV KUBE_LATEST_VERSION="v1.24.17" \
    KUBE_RUNNING_VERSION="v1.24.17" \
    HELM_VERSION="v3.14.3" \
    AWSCLI="1.24.10"

ENV HELM_TAR_FILE="helm-${HELM_VERSION}-linux-amd64.tar.gz" \
    HELM_URL="https://get.helm.sh" \
    HELM_BIN="helm3"

RUN apk --update --no-cache add \
    bash \
    ca-certificates \
    curl \
    jq \
    git \
    openssh-client \
    python3 \
    tar \
    wget \
    docker  \
    openrc \
    py3-pip

# Not something to be proud for
ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN pip3 install --upgrade pip
RUN pip3 install --no-cache requests awscli==${AWSCLI}

# Install kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_RUNNING_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install Helm3
RUN wget "${HELM_URL}/${HELM_TAR_FILE}" \
    && tar -xvzf ${HELM_TAR_FILE} \
    && chmod +x linux-amd64/helm \
    && cp linux-amd64/helm /usr/local/bin/$HELM_BIN \
    && ln -sfn /usr/local/bin/$HELM_BIN /usr/local/bin/helm \
    && rm -rf ${HELM_TAR_FILE} linux-amd64 \
    && helm version

# Install latest kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl_latest \
  && chmod +x /usr/local/bin/kubectl_latest

# Install envsubst
ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

# Install Helm plugins
#RUN helm init --client-only
#RUN helm plugin install https://github.com/databus23/helm-diff

WORKDIR /work

CMD ["tail", "-f", "/dev/null"]
