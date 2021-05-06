#!/bin/sh
set -e

start_pm2()
{
  PATH_TO_ECOSYSTEM="/var/www/pm2/ecosystem.config.yml"
  SIZE=$(yq e '.apps | length' ${PATH_TO_ECOSYSTEM})
  INDEX=0
  ONLY=""

  while [ ${INDEX} -lt ${SIZE} ]; do
    COMMAND=$(APPS_INDEX=${INDEX} yq e '[ .apps[env(APPS_INDEX)].script,.apps[env(APPS_INDEX)].args ] | join(" ")' ${PATH_TO_ECOSYSTEM})
    APP_NAME=$(APPS_INDEX=${INDEX} yq e '.apps[env(APPS_INDEX)].name' ${PATH_TO_ECOSYSTEM})
    INDEX=$((INDEX+1))

    set +e
    $COMMAND --help >/dev/null 2>&1
    set -e

    if [ "${?}" != "0" ]; then
      continue
    fi

    if [ ! -z "${ONLY}" ]; then
      ONLY="${ONLY},"
    fi

    ONLY="${ONLY}${APP_NAME}"
  done

  if [ ! -z "${ONLY}" ]; then
    pm2 start $PATH_TO_ECOSYSTEM --only ${ONLY}
  fi
}

if [ -d "${PATH_TO_JELLYFISH}/public" ] && [ ! -L "/var/www/html" ]; then
  rm -Rf /var/www/html
  ln -s ${PATH_TO_JELLYFISH}/public /var/www/html
fi

if [ ! -f "/usr/local/etc/php/conf.d/zzz-docker-php-ext-xdebug.ini" ]; then
  start_pm2
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

exec "$@"
