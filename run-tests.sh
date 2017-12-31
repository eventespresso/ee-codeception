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
    docker-compose run --rm acceptance-tests${BROWSER} $@
    docker stop $(docker ps -aq)
done