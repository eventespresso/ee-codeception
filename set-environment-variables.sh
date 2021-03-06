#!/usr/bin/env bash
# check for codeception.yml
CODECEPTCONFIG="codeception.yml"
if [ ! -f ./${CODECEPTCONFIG} ]; then
    CODECEPTCONFIG="codeception.dist.yml"
    if [ ! -f ./${CODECEPTCONFIG} ]; then
        echo 'codeception.yml missing'
        exit;
    fi
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

eval $(parse_yaml ./${CODECEPTCONFIG})
##define some constants
DB_HOST=${DB_HOST-localhost}
DB_USER=${DB_USER-$modules_config_WPDb_user}
DB_PASS=${DB_PASS-$modules_config_WPDb_password}
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DB_NAME=$modules_config_WPDb_dsn
DB_NAME=${DB_NAME#*dbname=}
WP_SITE_URL=$modules_config_WPWebDriver_url
SERVER_PATH="$( cd ${PROJECT_ROOT} && cd ../ && pwd)"
WP_SITE_PATH="$SERVER_PATH/www/wp"
#WEB_HOST=$(nslookup php-server 2>&1  | grep 'Address' | awk '{print $3}')
WEB_HOST=eecodeception.test
HAS_MAILCATCHER=1
#MAILCATCHER_IP_ADDRESS=$(nslookup mailcatcher 2>&1 | grep 'Address' | awk '{print $3}')
MAILCATCHER_HOST=mailcatcher

echo ---------- HOST NAME OF WEB SERVER -------------
echo ${WEB_HOST}
echo -------------------------------------------------

echo ---------- MAILCATCHER DETAILS ------------------
echo ${MAILCATCHER_HOST}
echo --------------------------------------------------


##EE core constants
if [ -z "$EE_BRANCH" ]; then
    EE_BRANCH="master"
fi

#Tags override branches.
if [ -n "$EE_TAG" ]; then
    EE_BRANCH=$EE_TAG
fi

## For notifications etc.
if [ -n "$ADDON_PACKAGE" ]; then
    ARTIFACT_PROJECT_SLUG=${ADDON_PACKAGE}
elif [ -n "$EE_TAG" ]; then
    ARTIFACT_PROJECT_SLUG="event-espresso-core-v${EE_TAG}"
elif [ -n "$EE_BRANCH" ]; then
    ARTIFACT_PROJECT_SLUG="event-espresso-core-${EE_BRANCH}"
else
    ARTIFACT_PROJECT_SLUG="event-espresso-core-master"
fi