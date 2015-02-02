#!/bin/bash -eux
if [ ! -f /.tomcat_admin_created ]; then
    /app/bin/create_tomcat_user.sh
fi

envsubst '$ADMIN_EMAIL:$ADMIN_PASSWORD:$USERGRID_URL:$MAIL_USER:$MAIL_PASSWORD:$MAIL_HOST:$MAIL_PORT' < /app/etc/usergrid.properties > /tomcat/lib/usergrid.properties
cat /tomcat/lib/usergrid.properties
while ! nodetool -host localhost info
do
    sleep 10
    echo "Waiting for cassandra..."
done
sleep 20
/sbin/setuser app /tomcat/bin/catalina.sh run