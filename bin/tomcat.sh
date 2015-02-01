if [ ! -f /.tomcat_admin_created ]; then
    /app/bin/create_tomcat_user.sh
fi

exec /sbin/setuser app /tomcat/bin/catalina.sh run