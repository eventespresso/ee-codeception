#!/usr/bin/env bash

## load common if log not declared
declare -F log &>/dev/null && echo "" || source common.sh

## set defaults
MY_GROUP='accuser'
MY_USER='accuser'

###
### Setup Group
###
if ! set | grep '^HOST_GROUP_ID=' >/dev/null 2>&1; then
	log "warn" "\$HOST_GROUP_ID not set"
	log "warn" "Keeping default group of 'accuser'"
	run "addgroup -S ${MY_GROUP}"
else
	if ! isint "${HOST_GROUP_ID}"; then
		log "err" "\$HOST_GROUP_ID is not an integer: '${HOST_GROUP_ID}'"
		exit 1
	else
		log "info" "Setting group 'accuser' gid to: ${HOST_GROUP_ID}"
		run "addgroup -S ${MY_GROUP}"
	fi
fi

if ! set | grep '^HOST_USER_ID=' >/dev/null 2>&1; then
	log "warn" "\$HOST_USER_ID not set"
	log "warn" "Setting user to default 'accuser'"
	run "adduser -S -s /bin/bash -G ${MY_GROUP} ${MY_USER}"
else
	if ! isint "${HOST_USER_ID}"; then
		log "err" "\$HOST_USER_ID is not an integer: '${HOST_USER_ID}'"
		exit 1
	else
		log "info" "Setting user to 'accuser' with uid of: ${HOST_USER_ID}"
		run "adduser -S -s /bin/bash -u ${HOST_USER_ID} -G ${MY_GROUP} ${MY_USER}"
	fi
fi

#adduser with passwordless sudo and change password of user to secret
echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers
echo 'accuser:secret' | chpasswd

### Change ownership of all the files in the user directory.
run "chown -R ${MY_USER}:${MY_GROUP} /home/accuser"
