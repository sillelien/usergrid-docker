#!/usr/bin/env bash
set -ex
cd usergrid
mkdir -p build
cd build
mkdir -p dist
[ -f dsc-cassandra-2.1.9-bin.tar.gz ] || wget http://downloads.datastax.com/community/dsc-cassandra-2.1.9-bin.tar.gz -O dsc-cassandra-2.1.9-bin.tar.gz
[ -d dsc-cassandra-2.1.9 ] || tar -xvzf dsc-cassandra-2.1.9-bin.tar.gz
[ -d cassandra ] || ( rm -rf dist/cassandra && cp -r dsc-cassandra-2.1.9 dist/cassandra )
[ -d usergrid ] || git clone https://github.com/apache/usergrid.git usergrid
cd usergrid
git checkout ${USERGRID_BRANCH}
cd stack
mvn -q -DskipTests=true -Dproject.build.sourceEncoding="UTF-8"  package
mv rest/target/ROOT.war ../../dist
cd ..
cd portal
chmod u+x build.sh
npm-install-missing
./build.sh
cp dist/usergrid-portal.tar ../../dist
cd ..
cd ..
cd ..
docker build -t usergrid .
cd ..
cd cassandra
docker build -t cassandra .
