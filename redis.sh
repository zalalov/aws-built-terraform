#!/bin/bash

apt-get -y install redis-server
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/'
service redis-server restart