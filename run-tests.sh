#!/usr/bin/env bash

source `dirname $0`

while getopts "hsb:t:a:f:x:e:" opt
do
    case ${opt} in
        e) TEST_ENV=$OPTARG;;
    esac
done

TEST_ENV=${TEST_ENV-"chrome"}
RUN_WITH=""

#SET HOST USER AND GROUP IDS these will get used by the entry scripts for the containers.
HOST_USER_ID=$(id -u)
HOST_GROUP_ID=$(id -g)

echo '----------- USER ID DETAILS OUTSIDE CONTAINER -----------'
echo "Host User ID: ${HOST_USER_ID}"
echo "Host Group ID: ${HOST_GROUP_ID}"
echo '---------------------------------------------------------'

RUN_CHROME_DEBUG=`echo "${TEST_ENV}" | sed 's/chromedebug//'`
if [ "${TEST_ENV}" != "${RUN_CHROME_DEBUG}" ]
then
    RUN_WITH="${RUN_WITH}-chrome-debug "
fi

if [ -z "$RUN_WITH" ]; then
    RUN_CHROME=`echo "${TEST_ENV}" | sed 's/chrome//'`
    if [ "${TEST_ENV}" != "${RUN_CHROME}" ]
    then
        RUN_WITH="${RUN_WITH}-chrome "
    fi
fi

if [ -z "$RUN_WITH" ]; then
    RUN_FIREFOX_DEBUG=`echo "${TEST_ENV}" | sed 's/firefoxdebug//'`
    if [ "${TEST_ENV}" != "${RUN_FIREFOX_DEBUG}" ]
    then
        RUN_WITH="${RUN_WITH}-firefox-debug "
    fi
fi

if [ -z "$RUN_WITH" ]; then
    RUN_FIREFOX=`echo "${TEST_ENV}" | sed 's/firefox//'`
    if [ "${TEST_ENV}" != "${RUN_FIREFOX}" ]
    then
        RUN_WITH="${RUN_WITH}-firefox "
    fi
fi

if [ -z "$RUN_WITH" ]; then
    RUN_PHANTOMJS=`echo "${TEST_ENV}" | sed 's/phantomjs//'`
    if [ "${TEST_ENV}" != "${RUN_PHANTOMJS}" ]
    then
        RUN_WITH="${RUN_WITH}-phantomjs "
    fi
fi

for BROWSER in "${RUN_WITH}"
do
    #make sure all images are up to date
    docker-compose pull acceptance-tests${BROWSER}
    docker-compose run --rm -e HOST_USER_ID=${HOST_USER_ID} -e HOST_GROUP_ID=${HOST_GROUP_ID} acceptance-tests${BROWSER} $@
    if [ $? -eq 0 ]; then
        docker stop $(docker ps -aq)
        exit 0
    else
        docker stop $(docker ps -aq)
        exit 1
    fi
done