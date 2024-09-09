ARG BASE_REGISTRY=registry.access.redhat.com/ubi8
ARG BASE_IMAGE=ubi
ARG BASE_TAG=8.10

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

# add our user and group first to make sure their IDs get assigned consistently, 
# regardless of whatever dependencies get added
RUN groupadd -r mongodb && useradd -r -g mongodb mongodb \
    && mkhomedir_helper mongodb;

COPY /packages/*.rpm /tmp/mongo_install/
COPY /config/* /tmp/mongo_install/
COPY /packages/gosu /usr/local/bin/gosu
COPY /packages/js-yaml.js /
COPY /scripts/docker-entrypoint.sh /usr/local/bin/
COPY /resources/mongod.conf /etc/mongod.conf

RUN set -eux \
    && dnf update -y --nodocs --disableplugin=subscription-manager \
    && dnf install -y ca-certificates jq procps \
    && rpm --import /tmp/mongo_install/server-7.0.asc \
    && dnf install -y /tmp/mongo_install/mongodb-mongosh.rpm \
        /tmp/mongo_install/mongodb-database-tools.rpm \
        /tmp/mongo_install/mongodb-enterprise-database-tools-extra.rpm \
        /tmp/mongo_install/mongodb-enterprise-tools.rpm \
        /tmp/mongo_install/mongodb-enterprise-server.rpm \
        /tmp/mongo_install/mongodb-enterprise-cryptd.rpm \
        /tmp/mongo_install/mongodb-enterprise-mongos.rpm \
        /tmp/mongo_install/mongodb-mongosh.rpm \
        /tmp/mongo_install/mongodb-enterprise-database.rpm \
        /tmp/mongo_install/mongodb-enterprise.rpm \
    && rm -rf /tmp/mongo_install \
    && dnf clean all \
    && rm -rf /var/cache/yum \
    # Rule Version (STIG-ID): MD7X-00-002400, MD7X-00-002500, MD7X-00-002700
    && chown mongod:mongod /etc/mongod.conf \
    # Rule Version (STIG-ID): MD7X-00-002300, MD7X-00-005500, MD7X-00-005600
    && chmod 600 /etc/mongod.conf \
    && chmod +x /usr/local/bin/gosu \
    && mkdir -p /data/db /data/configdb /data/logs /data/auditlog \
    # Rule Version (STIG-ID): MD7X-00-002800
    && chown -R mongodb:mongodb /data/db /data/configdb /data/logs /data/auditlog \
    && chmod 700 /data/auditlog \
    && chmod -R 750 /data/db /data/configdb /data/logs \
    && mkdir /docker-entrypoint-initdb.d \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

VOLUME /data/db /data/configdb /data/logs /data/auditlog

USER mongodb:mongodb

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 27017
CMD ["mongod", "-f", "/etc/mongod.conf"]

HEALTHCHECK NONE

