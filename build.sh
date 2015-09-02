#!/usr/bin/env bash
set -ex
cd usergrid
mkdir -p build
cd build
mkdir -p dist
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