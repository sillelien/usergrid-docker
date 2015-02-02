#!/bin/bash -eux
if [ ! -f /.tomcat_admin_created ]; then
    /app/bin/create_tomcat_user.sh
fi

/sbin/setuser app /tomcat/bin/catalina.sh run