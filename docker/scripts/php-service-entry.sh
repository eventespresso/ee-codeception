#!/usr/bin/env bash

## load common if log not declared
declare -F log &>/dev/null && echo "" || source common.sh

log "info" "Running on host: $(hostname)"

## setup user if necessary
if [ $(id accuser >/dev/null 2>&1) ]; then
    log "info" "'accuser' user already exists no need to setup"
else
    source ./setup-user.sh
fi

### setup wp-cli and composer if necessary
declare -F wp &>/dev/null && log "info" "'wp' and 'composer' already setup'" || su - ${MY_USER} -c './setup-composer-and-wp.sh'

php-fpm7 -F