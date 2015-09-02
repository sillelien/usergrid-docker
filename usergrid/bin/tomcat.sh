#!/usr/bin/with-contenv  bash
set -eux
if [ ! -f /.tomcat_admin_created ]; then
    /app/bin/create_tomcat_user.sh
fi

export CASS_URL=$CASS_PORT_9042_TCP_ADDR:$CASS_PORT_9042_TCP_PORT

envsubst '$ADMIN_EMAIL:$ADMIN_PASSWORD:$USERGRID_URL:$MAIL_USER:$MAIL_PASSWORD:$MAIL_HOST:$MAIL_PORT:$CASS_URL' < /app/etc/usergrid.properties > /tomcat/lib/usergrid.properties
cat /tomcat/lib/usergrid.properties
while ! nodetool -host $CASS_PORT_9042_TCP_ADDR -port $CASS_PORT_9042_TCP_PORT info
do
    sleep 10
    echo "Waiting for cassandra..."
done
sleep 20
s6-setuidgid app /tomcat/bin/catalina.sh run