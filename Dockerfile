FROM centos:7
MAINTAINER Mark McKinstry <mmckinst@redhat.com>

ENV PUPPET_SERVER_VERSION="2.7.2"
ENV DUMB_INIT_VERSION="1.2.0"
ENV PUPPETSERVER_JAVA_ARGS="-Xms256m -Xmx256m"
ENV PUPPET_USER_ID="1234"
ENV PUPPET_GROUP_ID="1234"
ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

RUN groupadd -g $PUPPET_GROUP_ID puppet
RUN useradd -u $PUPPET_USER_ID -r --gid puppet \
    --home /opt/puppetlabs/server/data/puppetserver \
    --shell /bin/false --comment "puppetserver daemon" puppet

# git is used by r10k
# the 'which' package is needed by puppetservers install script
RUN yum -y install git which && \
    yum -y install https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm && \
    yum -y install puppetserver-"$PUPPET_SERVER_VERSION" && \
    yum clean all && \
    gem install --no-rdoc --no-ri r10k
RUN curl -Lo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 && chmod +x /usr/local/bin/dumb-init

RUN sed -i "/^JAVA_ARGS/cJAVA_ARGS='${PUPPETSERVER_JAVA_ARGS}'" /etc/sysconfig/puppetserver

COPY logback.xml /etc/puppetlabs/puppetserver/
COPY request-logging.xml /etc/puppetlabs/puppetserver/
COPY Puppetfile Puppetfile
COPY puppet.conf /etc/puppetlabs/puppet/
COPY r10k.yaml /etc/puppetlabs/r10k/r10k.yaml

VOLUME /etc/puppetlabs/puppet/ssl/ \
       /opt/puppetlabs/server/data/puppetserver/


EXPOSE 8140

COPY Dockerfile /
