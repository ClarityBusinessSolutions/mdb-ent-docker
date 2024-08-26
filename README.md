# mdb-ent-docker

This is a Docker image of MongoDB Enterprise 7.0.11


## Building

Before building the image, you must download the requirements for the image. Scripts have been included
to download the following requriements:

* mongodb-enterprise-mongos.rpm
* mongodb-enterprise.rpm
* mongodb-enterprise-database.rpm
* mongodb-enterprise-server.rpm
* mongodb-enterprise-tools.rpm
* mongodb-database-tools.rpm
* mongodb-enterprise-database-tools-extra.rpm
* mongodb-mongosh.rpm
* mongodb-enterprise-cryptd.rpm
* GOSU
* JS-YAML

To download the requirements for x86 processers, run the `requirements.sh` file.

```shell
chmod +x requirements.sh
./requirements.sh
```

Requirements for ARM/Apple silicon based computers, run the `requirements-apple.sh` file.

```shell
chmod +x requirements-apple.sh
./requirements-apple.sh
```

## Building the Docker Image

```shell
docker build --no-cache  -t mongo-ent:7.0.11
```

## Run the image

The Dockerfile creates mount points for the following data directories:

* _dbpath_: /data/db
* _logpath_: /data/logs
* _auditPath_: /data/auditlog/auditLog.bson

The directories have bee created with the correct permissions applied.

The following flags must be supplied to the container when starting:

**[--port](https://www.mongodb.com/docs/manual/reference/program/mongod/#std-option-mongod.--port)**: The TCP port on which the MongoDB instance listens for client connections. The default is 27017. STIGs recommend not running on the default port.

**[--dbpath](https://www.mongodb.com/docs/manual/reference/program/mongod/#std-option-mongod.--dbpath)**: The directory where the mongod instance stores its data. *NOTE:* the Dockerfile assumes this path is `/data/db`. Changing this path will require you to change the ownership and permissions of the data directory in the Dockerfile.

**[--logpath](https://www.mongodb.com/docs/manual/reference/program/mongod/#std-option-mongod.--logpath)**: Sends all diagnostic logging information to a log file instead of to standard output or to the host's syslog system. MongoDB creates the log file at the path you specify. *NOTE:* the Dockerfile assumes this path is `/data/logs`. Changing this path will require you to change the ownership and permissions of the logs directory in the Dockerfile.

**[--auditDestination](https://www.mongodb.com/docs/manual/reference/program/mongod/#std-option-mongod.--auditDestination)**: Enables auditing and specifies where mongod sends all audit events. *NOTE:* the Dockerfile assumes this path is `/data/auditlog/auditLog.bson`. Changing this path will require you to change the ownership and permissions of the data audit logs in the Dockerfile.

**[--auditFormat](https://www.mongodb.com/docs/manual/reference/program/mongod/#std-option-mongod.--auditFormat)**: Specifies the format of the output file for auditing if `--auditDestination` is file. 

--auditPath /data/auditlog/auditLog.bson \

**[--auth]()**: Enables authorization to control user's access to database resources and operations. When authorization is enabled, MongoDB requires all clients to authenticate themselves first in order to determine the access for the client.

**[--noscripting](https://www.mongodb.com/docs/manual/reference/program/mongod/#std-option-mongod.--noscripting)**: Disables the scripting engine.

**[--redactClientLogData](https://www.mongodb.com/docs/manual/reference/program/mongod/#std-option-mongod.--redactClientLogData)**: A mongod running with `--redactClientLogData` redacts any message accompanying a given log event before logging. This prevents the mongod from writing potentially sensitive data stored on the database to the diagnostic log. Metadata such as error or operation codes, line numbers, and source file names are still visible in the logs.

**[--setParameter auditAuthorizationSuccess=true](https://www.mongodb.com/docs/manual/reference/parameters/#mongodb-parameter-param.auditAuthorizationSuccess)**: Enables the auditing of authorization successes for the authCheck action.

**[--setParameter authenticationMechanisms=SCRAM-SHA-256](https://www.mongodb.com/docs/manual/reference/parameters/#mongodb-parameter-param.authenticationMechanisms)**: Specifies the list of authentication mechanisms the server accepts. Set this to one or more of the following values. If you specify multiple values, use a comma-separated list and no spaces. This should be set to `SCRAM-SHA-256` unless using X.509 Certificates, Kerberos, or LDAP SASL. For more information, please review the [authenticationMechanisms](https://www.mongodb.com/docs/manual/reference/parameters/#mongodb-parameter-param.authenticationMechanisms) documentation.


### Launching

The following docker commands will create volumes for mongdb_data, mongodb_logs and mongodb_audit. These volumes will be used to store the MongoDB data, logs and audit logs respectively. These volumes will then be used to launch the Docker image which will run on port 27018.

```shell
docker run -d \
  --name mongodb-srv \
  -p 27018:27018 \
  -v mongodb_data:/data/db \
  -v mongodb_logs:/data/logs \
  -v mongodb_audit:/data/auditlog \
  mongo-ent:7.0.11 \
  --port 27018 \
  --dbpath /data/db \
  --logpath /data/logs/mongod.log \
  --auditDestination file \
  --auditFormat BSON \
  --auditPath /data/auditlog/auditLog.bson \
  --auth \
  --setParameter auditAuthorizationSuccess=true \
  --setParameter authenticationMechanisms=SCRAM-SHA-256 \
  --noscripting \
  --redactClientLogData
```

Once the docker container is running, you will be required to create a initial user. Connect to the container and use the MongoDB shell:

```shell
docker exec -it mongodb mongosh --port 27018
```

Use the `admin` database and execute the `createUser` command to create the intial user:

```shell
use admin
db.createUser({
  user: "adminUser",
  pwd: "securePassword",
  roles: [ { role: "root", db: "admin" } ]
})
```


