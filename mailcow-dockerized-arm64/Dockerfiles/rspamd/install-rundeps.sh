#!/bin/bash

if [ "$(dpkg --print-architecture)" = "amd64" ]; then
  apt-get install -y libhyperscan5 libluajit-5.1-2
else
  apt-get install -y liblua5.1-0
fi
