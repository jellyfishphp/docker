#!/bin/sh
set -e

PATH_TO_JELLYFISH_CLI="/var/www/jellyfish/releases/current/vendor/bin/console"

while true
do
   php $PATH_TO_JELLYFISH_CLI scheduler:run 2>&1 > /dev/null &
   sleep 1m
done
