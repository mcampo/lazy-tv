#!/usr/bin/env bash

curl 'https://github.com/revarbat/BOSL/archive/v1.0.zip' -L -o bosl.zip
unzip bosl.zip -d lib
rm bosl.zip
mv lib/BOSL-1.0 lib/BOSL

curl 'https://github.com/mcampo/scad-lib/archive/master.zip' -L -o scad-lib.zip
unzip scad-lib.zip -d lib
rm scad-lib.zip
mv lib/scad-lib-master lib/scad-lib
