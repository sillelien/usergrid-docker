#!/bin/bash -eux
if [ ! -f /.tomcat_admin_created ]; then
    /app/bin/create_tomcat_user.sh
fi

envsubst '$ADMIN_EMAIL:$ADMIN_PASSWORD:$USERGRID_URL:$MAIL_USER:$MAIL_PASSWORD:$MAIL_HOST:$MAIL_PORT' < /app/etc/usergrid.properties > /tomcat/lib/usergrid.properties

/sbin/setuser app /tomcat/bin/catalina.sh run