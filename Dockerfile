FROM oraclelinux:7-slim
MAINTAINER Simon Smith <simon.r.smith@gmail.com>

ARG IMAGE_VERSION

ENV PATH=${PATH}:/opt/rh/devtoolset-7/root/bin \
    LANG=C.UTF-8

#WORKDIR /tmp

COPY ./etc/yum.repos.d/oracle-developer-ol7.repo /etc/yum.repos.d/oracle-developer-ol7.repo
COPY ./etc/yum.repos.d/oracle-epel-ol7.repo /etc/yum.repos.d/oracle-epel-ol7.repo
COPY ./etc/yum.repos.d/oracle-linux-ol7.repo /etc/yum.repos.d/oracle-linux-ol7.repo
COPY ./etc/yum.repos.d/oracle-softwarecollection-ol8.repo /etc/yum.repos.d/oracle-softwarecollection-ol8.repo
COPY ./etc/yum.repos.d/runner_gitlab-runner.repo /etc/yum.repos.d/runner_gitlab-runner.repo
COPY ./bin/gitlab-runner /usr/local/bin/gitlab-runner
COPY ./requirements.txt /requirements.txt
COPY ./entrypoint /entrypoint

RUN set -ex && \
   yum-config-manager --enable ol7_optional_latest && \
   yum -y update && \
   yum -y install $(cat requirements.txt)

CMD ["/entrypoint"]
