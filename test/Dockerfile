FROM sillelien/base-alpine
RUN apk add curl
CMD sleep 60 && curl http://${USERGRID_PORT_8800_TCP_ADDR}:${USERGRID_PORT_8800_TCP_PORT}/