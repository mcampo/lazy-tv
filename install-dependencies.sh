#!/usr/bin/env bash

curl 'https://github.com/revarbat/BOSL/archive/v1.0.3.zip' -L -o bosl.zip
unzip bosl.zip -d lib
rm bosl.zip
mv lib/BOSL-1.0.3 lib/BOSL

