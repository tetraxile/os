#!/bin/sh

cut -d'#' -f1 < hex2bin.hex | xxd -p -r > ./hex2bin && chmod +x ./hex2bin