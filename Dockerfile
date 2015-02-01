FROM phusion/baseimage:0.9.16
MAINTAINER Neil Ellis hello@neilellis.me
VOLUME /data
EXPOSE 80

CMD ["/sbin/my_init"]

ENV HOME /root
ENV GITHUB_USER neilellis
ENV GITHUB_PROJECT codeserver-example
ENV GITHUB_BRANCH master
ENV PAID_AC false
ENV HOME /root
ENV SLIMERJS_VERSION_M 0.9
ENV SLIMERJS_VERSION_F 0.9.4
ENV VERTX_VERSION 2.1.5
ENV TYK_VERSION 1.3
# ENV PHANTOM_VERSION 1.9.8

WORKDIR /root

RUN adduser --disabled-password --gecos '' app


############################### END OF INITIAL ################################

COPY etc/datastax.gpg /tmp/datastax_key

# Setup Apt-Get
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty multiverse" >> /etc/apt/sources.list   && \
    echo "deb http://archive.ubuntu.com/ubuntu trusty-updates multiverse" >> /etc/apt/sources.list  && \
    echo "deb http://archive.ubuntu.com/ubuntu trusty-security multiverse" >> /etc/apt/sources.list && \
    curl -sL https://deb.nodesource.com/setup | sudo bash - && \
    sed -i.bak 's/main$/main universe/' /etc/apt/sources.list && \
    add-apt-repository -y ppa:webupd8team/java  && \
    add-apt-repository -y ppa:nginx/stable && \
    apt-key add /tmp/datastax_key && \
    echo "deb http://debian.datastax.com/community stable main" > /etc/apt/sources.list.d/datastax.list && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

# Install Base Packages
RUN apt-get update &&  apt-get install -y pwgen ca-certificates   \
    wget curl   dbus libdbus-glib-1-2  bzip2  nodejs git  \
    python-dev libssl-dev  gcc build-essential  gettext --no-install-recommends


############################### END OF PRE-REQS ################################



# Java
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
RUN rm -rf /var/cache/oracle-jdk8-installer && \
    echo "JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /etc/environment

# Misc
RUN apt-get update &&  apt-get install -y oracle-java8-installer maven nginx cassandra=2.0.10 dsc20=2.0.10-1  --no-install-recommends


# Tomcat

ENV TOMCAT_MAJOR_VERSION 7
ENV TOMCAT_MINOR_VERSION 7.0.55
ENV CATALINA_HOME /tomcat

RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
    wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    rm apache-tomcat-*.tar.gz && \
    mv apache-tomcat* /tomcat  && rm -r /tomcat/webapps/ROOT

# Cassandra

RUN rm -f /etc/security/limits.d/cassandra.conf

#RUN wget http://www.us.apache.org/dist/cassandra/1.2.16/apache-cassandra-1.2.16-bin.tar.gz && tar -xvzf apache-cassandra-1.2.16-bin.tar.gz && mv apache-cassandra-1.2.16 /cassandra

RUN git clone https://github.com/apache/incubator-usergrid.git /home/app/usergrid && ln -s /home/app /app   && mv /home/app/usergrid/portal /home/app &&  mv /home/app/usergrid/stack /home/app




############################### END OF APPS ##################################

# Clean
RUN apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /tmp/* /var/lib/apt/lists/*  /var/www

############################### END OF INSTALLS ###############################


WORKDIR /app

VOLUME /app_var
RUN ln -s /app_var /app/var  && mkdir /app/lib   && mkdir /app/log
RUN mkdir -p /app/var/cassandra && mkdir -p /app/log/cassandra && chown -R app:app /app/var/cassandra && chown -R app:app /app/log/cassandra  && ln -s  /app/var/cassandra /var/lib/cassandra && ln -s /app/log/cassandra /var/log/cassandra
RUN cd /app/stack && mvn clean install -DskipTests=true

COPY etc/ /app/etc/
RUN cp /app/stack/rest/target/ROOT.war /tomcat/webapps/ && cp /app/etc/usergrid.properties /tomcat/lib/

RUN cd /app/portal && chmod u+x build.sh
RUN cd /app/portal && ./build.sh
RUN cd /tomcat/webapps && tar -xvf /app/portal/dist/usergrid-portal.tar && mv usergrid* usergrid

RUN mkdir /etc/service/tomcat /etc/service/init /etc/service/nginx /etc/service/cassandra /app/tmp

COPY bin/ /app/bin/

RUN cp /app/etc/nginx.conf /etc/nginx/nginx.conf && \
    cp /app/bin/init.sh /etc/service/init/run && \
    cp /app/bin/nginx.sh /etc/service/nginx/run && \
    cp /app/bin/tomcat.sh /etc/service/tomcat/run && \
    cp /app/bin/cassandra.sh /etc/service/cassandra/run

RUN chmod 755 /etc/service/init/run /etc/service/tomcat/run  /etc/service/nginx/run  /etc/service/cassandra/run
RUN rm -rf /app/.m2  && rm -rf /app/portal  && rm -rf /app/stack && rm -rf /app/usergrid  && chown -R app:app /app /tomcat/webapps && chown -h app:app /app   /app/log/cassandra   /app/var/cassandra


