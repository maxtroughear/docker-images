#!/bin/bash

if [ "$(dpkg --print-architecture)" = "amd64" ]; then
  apt-get install -y libhyperscan5
fi
