# Set environment
ARG BASE_DIR=/opt/cmis-server

#####
# Preparation stage 
#####
FROM exoplatform/jdk:8-ubuntu-1804 AS install

ARG BASE_DIR
# Tomcat Version
ENV TOMCAT_VERSION_MAJOR 8
ENV TOMCAT_VERSION_FULL  8.5.39

# OpenCMIS
ENV OPENCMIS_VERSION 1.1.0
# fileshare or inmemory
ARG CMIS_SERVER_TYPE=fileshare  

RUN apt-get update
RUN apt-get install -y curl
RUN set -x \
  && mkdir -p /opt \
  && curl -LO https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz \
  && curl -LO https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz.sha512 \
  && sha512sum -c apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz.sha512 \
  && gunzip -c apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz | tar -xf - -C /opt \
  && mv -v /opt/apache-tomcat-${TOMCAT_VERSION_FULL} ${BASE_DIR} \
  && rm -f apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz.sha512 \
  && find ${BASE_DIR} -name "*.sh" -exec chmod u+x {} \; \
  && rm -rf ${BASE_DIR}/webapps/examples ${BASE_DIR}/webapps/docs ${BASE_DIR}/webapps/manager ${BASE_DIR}/webapps/host-manager

# Install extra components
RUN set -x \
  && cd /tmp \
  && curl -LO https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/extras/catalina-jmx-remote.jar \
  && curl -LO https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/extras/catalina-jmx-remote.jar.sha512 \
  && sha512sum -c catalina-jmx-remote.jar.sha512 \
  && cp catalina-jmx-remote.jar ${BASE_DIR}/lib

RUN set -x \
    && cd /tmp \
    && curl -LO https://repo1.maven.org/maven2/org/apache/chemistry/opencmis/chemistry-opencmis-server-${CMIS_SERVER_TYPE}/1.1.0/chemistry-opencmis-server-${CMIS_SERVER_TYPE}-${OPENCMIS_VERSION}.war \
    && mkdir ${BASE_DIR}/webapps/cmis \
    && cd ${BASE_DIR}/webapps/cmis \
    && unzip -qq /tmp/chemistry-opencmis-server-${CMIS_SERVER_TYPE}-${OPENCMIS_VERSION}.war -d .

RUN set -x \
    && cd /tmp \
    && curl -LO https://corretto.aws/downloads/resources/8.402.08.1/amazon-corretto-8.402.08.1-linux-x64.tar.gz \
    && mkdir ${BASE_DIR}/jdk-8 \
    && cd ${BASE_DIR}/jdk-8

RUN set -x \
    && tar xf /tmp/amazon-corretto-8.402.08.1-linux-x64.tar.gz \
    && mv /tmp/amazon-corretto-8.402.08.1-linux-x64/* ${BASE_DIR}/jdk-8

COPY bin/setenv.sh ${BASE_DIR}/bin

#####
# Final stage 
#####
FROM ubuntu:22.04

# thanks to eXo Platform
# https://github.com/exo-docker
LABEL maintainer="Caffetteria <caffetteria@gmail.com>"

ARG BASE_DIR
ENV INSTALL_DIR=${BASE_DIR}

# TOMCAT 
# Expose web port
EXPOSE 8080

ENV CMIS_USERS_PASSWORD=cm1sp@ssword

RUN apt-get -qq update \
  && apt-get -qq -y upgrade ${_APT_OPTIONS} \
  && apt-get -qq -y install ${_APT_OPTIONS} xmlstarlet \
  && apt-get -qq -y autoremove \
  && apt-get -qq -y clean \
  && rm -rf /var/lib/apt/lists/*

# Prepare users and install directory
RUN set -x \
  && groupadd --gid 999 tomcat && useradd --gid tomcat -u 999 -s /bin/bash tomcat \
  && mkdir -p /opt /data/cmis \
  && chown -R tomcat:tomcat /data

COPY repository-template.properties /

# Copy the tomcat server already configured
COPY --chown=999 --from=install ${BASE_DIR} ${BASE_DIR}

VOLUME /data

USER tomcat

#ENTRYPOINT ["/usr/local/bin/tini", "--"]
CMD [ "/opt/cmis-server/bin/catalina.sh", "run" ]
