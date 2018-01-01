#!/usr/bin/env bash

source `dirname $0`

#change to main directory
#@todo this needs to be modified so its more dynamic and set externally.  But for now it'll do
cd /home/accuser/ee-codeception

usage() {
    echo "----------- run-tests.sh USAGE ---------------"
    echo "usage: ./run-tests.sh"
    echo "[ -h This usage instructions ] [ -s start from scratch ] [ -b ee-branch ] [ -t ee-core-tag ] [ -a ee-addon-package-slug ]"
    echo "example: To run tests with ee core branch 'FET-12345-some-work' on firefox."
    echo "$: ./run-tests.sh -e firefox -b FET-12345-some-work"
    echo "----------------------------------------------"
    exit 2
}

while getopts "Rhsb:t:a:f:e:" opt; do
    case ${opt} in
        h)k
            usage
            ;;
        b)
            export EE_BRANCH=$OPTARG
            ;;
        t)
            export EE_TAG=$OPTARG
            ;;
        a)
            export ADDON_PACKAGE=$OPTARG
            ;;
        x)
            export ADDON_BRANCH=$OPTARG
            ;;
        s)
            export START_FROM_SCRATCH=true
            ;;
        f)
            export FILES=${OPTARG}
            ;;
        e)
            export BROWSER=${OPTARG}
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
        \?)
            usage
            ;;
    esac
done

BROWSER=${BROWSER-chrome}

##make sure webservers are started
##./server-services start

source setup-tests.sh
if [ -n "$FILES" ]; then
    vendor/bin/codecept run acceptance ${FILES} --steps --env ${BROWSER}
else
    vendor/bin/codecept run --env ${BROWSER} --steps
fi
## stop webservers
##./server-services stop
