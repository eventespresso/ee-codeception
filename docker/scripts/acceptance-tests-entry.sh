#!/usr/bin/env bash

## load common if log not declared
declare -F log &>/dev/null && echo "" || source common.sh

log "info" "Running on host: $(hostname)"

## set defaults
MY_GROUP='accuser'
MY_USER='accuser'

## setup user if necessary
## setup user if necessary
if [ $(id accuser >/dev/null 2>&1) ]; then
    log "info" "'accuser' user already exists - deleting then resetting up with proper uids"
    delgroup ${MY_USER} ${MY_GROUP}
    deluser ${MY_USER}
    delgroup ${MY_GROUP}
    source ./setup-user.sh
else
    source ./setup-user.sh
    ### Change ownership of all the files in the user directory.
    run "chown -R ${MY_USER}:${MY_GROUP} /home/accuser"
fi

### setup wp-cli and composer if necessary
declare -F wp &>/dev/null && log "info" "'wp' and 'composer' already setup'" || su - ${MY_USER} -c './setup-composer-and-wp.sh'

ENTRY_COMMAND="source ee-codeception/do-tests.sh $@"

su -m ${MY_USER} -c "${ENTRY_COMMAND}"