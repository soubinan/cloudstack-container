FROM docker.io/redhat/ubi8-init:latest

LABEL maintainer="https://github.com/soubinan"

COPY ./cloudstack.repo /etc/yum.repos.d/cloudstack.repo

RUN yum update -y && yum upgrade -y && \
    yum clean all -y
RUN yum install cloudstack-management hostname -y && \
    yum clean all -y
RUN yum install nfs-utils -y && \
    yum clean all -y
RUN wget https://download.cloudstack.org/tools/vhd-util -O /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/vhd-util

COPY ./cloudstack-init.env /etc/default/cloudstack-init
COPY ./cloudstack-init.service /etc/systemd/system/cloudstack-init.service
COPY ./cloudstack-management.service /etc/systemd/system/cloudstack-management.service

RUN systemctl enable cloudstack-init && \
    systemctl enable cloudstack-management

HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -s --fail http://127.0.0.1:8080 || exit 1

EXPOSE 8080 8443 9090 8250
