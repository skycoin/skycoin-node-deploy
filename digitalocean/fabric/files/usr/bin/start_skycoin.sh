#!/bin/bash

/usr/local/bin/skycoin \
    -enable-gui=false \
    -launch-browser=false \
    -disable-csrf \
    -enable-api-sets="READ,TXN" \
    -web-interface-addr="0.0.0.0" \
    -web-interface-port="6420"
