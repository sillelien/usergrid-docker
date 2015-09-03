FROM ubuntu
RUN apt-get install -y curl
CMD sleep 60 && curl http://${USERGRID_PORT_8080_TCP_ADDR}:${USERGRID_PORT_8080_TCP_PORT}/ && sleep 2147483647