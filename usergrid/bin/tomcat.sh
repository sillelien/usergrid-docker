#!/usr/bin/with-contenv  bash
set -e
if [ ! -f /.tomcat_admin_created ]; then
    /app/bin/create_tomcat_user.sh
fi

export CASS_URL=${CASS_PORT_9160_TCP_ADDR}:${CASS_PORT_9160_TCP_PORT}

envsubst '$ADMIN_EMAIL:$ADMIN_PASSWORD:$USERGRID_URL:$MAIL_USER:$MAIL_PASSWORD:$MAIL_HOST:$MAIL_PORT:$CASS_URL' < /app/etc/usergrid.properties > /tomcat/lib/usergrid-custom.properties
cat /tomcat/lib/usergrid-custom.properties

while ! echo "" | socat - TCP:${CASS_PORT_9042_TCP_ADDR}:${CASS_PORT_9042_TCP_PORT}
do
    sleep 10
    echo "Waiting for Cassandra ..."
done

echo "Cassandra connected fine"

sleep 5

echo "Starting Tomcat"

exec s6-setuidgid app /tomcat/bin/catalina.sh run