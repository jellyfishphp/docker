#!/bin/sh
set -e

PATH_TO_SUPERVISOR_CONFIGS="/etc/supervisor/conf.d/"

if [ ! -f "${PATH_TO_SUPERVISOR_CONFIGS}ui.conf" ]; then
    envsubst < ${PATH_TO_SUPERVISOR_CONFIGS}ui.conf.template >${PATH_TO_SUPERVISOR_CONFIGS}ui.conf
fi

exec "$@"
