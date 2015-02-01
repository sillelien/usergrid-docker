#!/bin/bash -eu
while ! curl http://localhost:8080/status
do
    echo "Awaiting usergrid start."
    sleep 10
done
sleep infinity