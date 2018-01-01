#!/usr/bin/env bash

MY_USER=nginx
MY_GROUP=nginx
MY_ID=$(id -u nginx)
MY_GROUP_ID=$(id -g nginx)

source user-change.sh

nginx -g daemon off;