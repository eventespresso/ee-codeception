#!/usr/bin/env bash
# check for codeception.yml
if [ ! -f ./codeception.yml ]; then
    echo 'codeception.yml missing'
    exit;
fi

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

eval $(parse_yaml ./codeception.yml)
##define some constants
DB_HOST=${DB_HOST-localhost}
DB_USER=${DB_USER-$modules_config_WPDb_user}
DB_PASS=${DB_PASS-$modules_config_WPDb_password}
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DB_NAME=$modules_config_WPDb_dsn
DB_NAME=${DB_NAME#*dbname=}
WP_SITE_URL=$modules_config_WPBrowser_url
SERVER_PATH="$PROJECT_ROOT/tests/tmp"
WP_SITE_PATH="$SERVER_PATH/wp"

##EE core constants
if [ -z "$EE_BRANCH" ]; then
    EE_BRANCH="master"
fi

#Tags override branches.
if [ -n "$EE_TAG" ]; then
    EE_BRANCH=$EE_TAG
fi