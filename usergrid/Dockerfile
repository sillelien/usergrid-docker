FROM sillelien/jessie
MAINTAINER Neil Ellis hello@neilellis.me
EXPOSE 80

CMD ["/sbin/my_init"]

ENV HOME /root
WORKDIR /root

RUN adduser --disabled-password --gecos '' app


############################### END OF INITIAL ################################

COPY etc/datastax.gpg /tmp/datastax_key

# Install Base Packages
RUN apt-get update &&  apt-get install -y pwgen ca-certificates   \
    wget curl dbus libdbus-glib-1-2  bzip2  software-properties-common   \
    python-dev libssl-dev  gcc build-essential  gettext --no-install-recommends


# Setup Apt-Get
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty multiverse" >> /etc/apt/sources.list   && \
    echo "deb http://archive.ubuntu.com/ubuntu trusty-updates multiverse" >> /etc/apt/sources.list  && \
    echo "deb http://archive.ubuntu.com/ubuntu trusty-security multiverse" >> /etc/apt/sources.list && \
    sed -i.bak 's/main$/main universe/' /etc/apt/sources.list && \
    add-apt-repository -y ppa:webupd8team/java  && \
    apt-key add /tmp/datastax_key && \
    echo "deb http://debian.datastax.com/community stable main" > /etc/apt/sources.list.d/datastax.list && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections



############################### END OF PRE-REQS ###############################



# Java
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle
RUN rm -rf /var/cache/oracle-jdk7-installer && \
    echo "JAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /etc/environment

# Misc
RUN apt-get update &&  apt-get install -y oracle-java7-installer maven nginx --no-install-recommends


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
#RUN rm -f /etc/security/limits.d/cassandra.conf
#RUN apt-get update &&  apt-get install -y cassandra=2.0.10 dsc20=2.0.10-1  --no-install-recommends

#RUN wget http://www.us.apache.org/dist/cassandra/1.2.16/apache-cassandra-1.2.16-bin.tar.gz && tar -xvzf apache-cassandra-1.2.16-bin.tar.gz && mv apache-cassandra-1.2.16 /cassandra

RUN  ln -s /home/app /app


############################### END OF APPS ###################################

# Clean
RUN apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /tmp/* /var/lib/apt/lists/*  /var/www

############################### END OF INSTALLS ###############################



# Prep directory structure
VOLUME /home/app/var
VOLUME /var/lib/cassandra

RUN mkdir /home/app/lib   && mkdir /home/app/log   && mkdir /home/app/tmp
RUN chown -R app:app  /home/app  /tomcat && chown -h app:app /app /home/app/var
RUN ln -s /var/log/cassandra /home/app/log/cassandra

USER app
ENV HOME /home/app
WORKDIR /home/app

# Build server
ENV USERGRID_BRANCH master


# Add config
COPY etc/ /app/etc/

ENV ADMIN_EMAIL me@example.com
ENV ADMIN_PASSWORD admin
ENV USERGRID_URL http://localhost:8080/
ENV MAIL_HOST mail.example.com
ENV MAIL_PORT 123
ENV MAIL_USER ""
ENV MAIL_PASSWORD ""


#Setup tomcat
COPY build/dist/ROOT.war /tomcat/webapps/

# Build Portal
COPY build/dist/usergrid-portal.tar /tmp


# Add to Tomcat
RUN cd /tmp && tar -xvf /tmp/usergrid-portal.tar && mv usergrid-portal* /home/app/public && rm -rf /tmp/*

COPY bin/ /app/bin/

USER root
RUN chown app:app /app/bin/* && chmod 755 /app/bin/*


COPY etc/nginx.conf /etc/nginx/nginx.conf
COPY bin/init.sh /etc/cont-init.d/usergrid
COPY bin/nginx.sh /etc/services.d/nginx/run
COPY /app/bin/tomcat.sh /etc/services.d/tomcat/run

RUN chmod 755 /etc/cont-init.d/usergrid /etc/services.d/nginx/run  /etc/services.d/tomcat/run


############################### END OF BUILD ##################################