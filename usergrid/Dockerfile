FROM sillelien/jessiej
MAINTAINER Neil Ellis hello@neilellis.me
EXPOSE 80

RUN adduser --disabled-password --gecos '' app


############################### END OF INITIAL ################################


# Install Base Packages
RUN apt-get update &&  apt-get install -y pwgen ca-certificates nginx wget curl gettext --no-install-recommends && \
    apt-get clean all -y && apt-get purge -y && apt-get autoremove -y && rm -rf /tmp/* /var/lib/apt/lists/*


############################### END OF PRE-REQS ###############################

# Tomcat

ENV TOMCAT_MAJOR_VERSION 7
ENV TOMCAT_MINOR_VERSION 7.0.55

RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
    wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    rm apache-tomcat-*.tar.gz && \
    mv apache-tomcat* /tomcat  && rm -r /tomcat/webapps/ROOT


RUN  ln -s /home/app /app


############################### END OF APPS ###################################


############################### END OF INSTALLS ###############################

RUN mkdir /home/app/lib   && mkdir /home/app/log   && mkdir /home/app/tmp
RUN chown -R app:app  /home/app  /tomcat


USER app
ENV HOME /home/app
WORKDIR /home/app

# Build server
ENV USERGRID_BRANCH master


# Add config
COPY etc/ /home/app/etc/

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
COPY build/dist/usergrid-portal.tar /tmp/home/app/public

COPY bin/ /home/app/bin/

USER root
RUN chown app:app /home/app/bin/* && chmod 755 /home/app/bin/*


COPY etc/nginx.conf /etc/nginx/nginx.conf
COPY bin/init.sh /etc/cont-init.d/usergrid
COPY bin/nginx.sh /etc/services.d/nginx/run
COPY bin/tomcat.sh /etc/services.d/tomcat/run

RUN chmod 755 /etc/cont-init.d/usergrid /etc/services.d/nginx/run  /etc/services.d/tomcat/run


############################### END OF BUILD ##################################