# Downloads all required files for local build and test

# Downloads a file and its SHA256 checksum,
# and maintains that information for insertion into the hardening manifest.
download_file () {
   local SHORTNAME=$1
   local FILENAME=$2
   local BASEURL=$3

   echo
   if [ ! -f $SHORTNAME ]
   then
     echo "Downloading $FILENAME..."
     # Using the -L option to follow any redirects.
     echo "curl -L -o ./packages/$SHORTNAME $BASEURL/$FILENAME"
     curl -L -o ./packages/$SHORTNAME $BASEURL/$FILENAME
   else
     echo "$FILENAME already downloaded."
   fi
}

# GOSU
# “For easy step-down from root”.
# Unclear why we need this, but it’s in our public image (copied from open source) as well as the Repo1 open source version.
# Our Dockerfile grabs it using wget (and requires gpg to do so: gosu-amd64.asc, etc.),
# but for Repo1 we have to download this locally (which means we don’t need wget or gpg).
# Downloading via curl requires the -L option, to follow the redirect.l
# And the URL it uses is: https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64
# To download it manually: https://github.com/tianon/gosu/releases
# Using 1.14 per our public Dockerfile.
# “gosu-amd64”, per Repo1 open source version.

GOSU_VERSION=1.14
dpkgArch=aarch64
download_file gosu-$dpkgArch gosu-$dpkgArch https://github.com/tianon/gosu/releases/download/$GOSU_VERSION
mv packages/gosu-aarch64 packages/gosu

# JQ: "like sed for JSON".
# Repo1 version fetches this locally, but our Dockerfile installs it via yum.
# "which jq" finds it in /usr/bin, so I think we're good.

# JS-YAML: "for parsing MongoDB YAML files"
# Present in our Dockerfile, but not in Repo1 version.
# Used by docker-entrypoint.sh script.
# We don't download the whole thing, just the js-yaml.js file.
JSYAML_VERSION=3.13.1
download_file js-yaml.js js-yaml.js https://github.com/nodeca/js-yaml/raw/${JSYAML_VERSION}/dist

# MongoDB binaries

# Mongo 7.0.11 Binaries - aarch64
download_file mongodb-enterprise-mongos.rpm \
              mongodb-enterprise-mongos-7.0.11-1.el8.aarch64.rpm \
              https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/7.0/aarch64/RPMS

download_file mongodb-enterprise.rpm \
              mongodb-enterprise-7.0.11-1.el8.aarch64.rpm \
              https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/7.0/aarch64/RPMS

download_file mongodb-enterprise-database.rpm \
              mongodb-enterprise-database-7.0.11-1.el8.aarch64.rpm \
              https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/7.0/aarch64/RPMS

download_file mongodb-enterprise-server.rpm \
              mongodb-enterprise-server-7.0.11-1.el8.aarch64.rpm \
              https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/7.0/aarch64/RPMS

download_file mongodb-enterprise-tools.rpm \
              mongodb-enterprise-tools-7.0.11-1.el8.aarch64.rpm \
              https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/7.0/aarch64/RPMS

download_file mongodb-database-tools.rpm \
              mongodb-database-tools-100.10.0-1.aarch64.rpm \
              https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/7.0/aarch64/RPMS

download_file mongodb-enterprise-database-tools-extra.rpm \
              mongodb-enterprise-database-tools-extra-7.0.11-1.el8.aarch64.rpm \
              https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/7.0/aarch64/RPMS

download_file mongodb-mongosh.rpm \
              mongodb-mongosh-2.2.9.aarch64.rpm \
              https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/7.0/aarch64/RPMS

download_file mongodb-enterprise-cryptd.rpm \
              mongodb-enterprise-cryptd-7.0.11-1.el8.aarch64.rpm \
              https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/7.0/aarch64/RPMS

echo
curl -L -o config/server-7.0.asc https://www.mongodb.org/static/pgp/server-7.0.asc
echo "Public key downloaded (server-7.0.asc)"
echo


echo
echo "All requested binaries downloaded to local folder for testing container build."
echo

