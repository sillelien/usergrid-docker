#!/bin/bash -eu
while ! ping -c 1 $CASS_PORT_9042_TCP_ADDR
do
    sleep 5
done
