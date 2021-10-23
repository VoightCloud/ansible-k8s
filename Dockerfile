FROM alpine:3.11

LABEL maintainer="jeff@voight.org"

RUN echo "===> Installing sudo to emulate normal OS behavior..."  && \
    apk --update add sudo                                         && \
    \
    \
    echo "===> Adding Python runtime..."  && \
    apk --update add python3 openssl ca-certificates    && \
    apk --update add --virtual build-dependencies \
                python3-dev libffi-dev openssl-dev build-base  && \
    pip3 install --upgrade pip cffi                            && \
    \
    \
    echo "===> Installing Ansible..."  && \
    pip3 install ansible==3.4.0         && \
    \
    \
    echo "===> Installing handy tools (not absolutely required)..."  && \
    pip3 install --upgrade pywinrm                  && \
    apk --update add sshpass openssh-client rsync  && \
    \
    \
    echo "===> Removing package list..."  && \
    apk del build-dependencies            && \
    rm -rf /var/cache/apk/*               && \
    \
    \
    echo "===> Adding hosts for convenience..."  && \
    mkdir -p /etc/ansible                        && \
    echo 'localhost' > /etc/ansible/hosts

RUN apk --no-cache --update add \
        bash \
        py-dnspython \
        py-boto \
        py-netaddr \
        bind-tools \
        html2text \
        php7 \
        php7-json \
        git \
        jq \
        curl

RUN pip3 install --no-cache-dir --upgrade yq

RUN pip3 install --no-cache-dir --upgrade mitogen
RUN ansible-galaxy collection install kubernetes.core

RUN pip3 install openshift

RUN mkdir -p /ansible/playbooks

RUN curl -L -o /usr/bin/kubectl "https://dl.k8s.io/release/v1.21.5/bin/linux/amd64/kubectl"
RUN chmod 755 /usr/bin/kubectl
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN mkdir -p /root/.kube

ENV PATH="/usr/local/bin:${PATH}"

WORKDIR /ansible/playbooks

VOLUME [ "/ansible/playbooks" , "/root/.kube"]

# default command: display Ansible version
CMD [ "ansible-playbook", "--version" ]
