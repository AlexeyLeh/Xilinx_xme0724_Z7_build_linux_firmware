#!/bin/bash

#rm -rf ./BOOT
rm -rf vivado-files/artifacts

chmod +x lnx/clean.sh
(cd ./lnx ; ./clean.sh)

