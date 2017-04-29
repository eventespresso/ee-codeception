#!/usr/bin/env bash
while getopts "hb:t:a:" opt; do
    case $opt in
        h)
            echo "\n\n\tusage: sh run-locally.sh [-h This usage instructions] [-b ee-branch] [-t ee-core-tag] [-a ee-addon-package-slug]"
            echo "\texample: To run tests with ee core branch 'FET-12345-some-work'"
            echo "\tsh run-locally.sh -b FET-12345-some-work\n\n"
            exit 1
            ;;
        b)
            EE_BRANCH=$OPTARG
            ;;
        t)
            EE_TAG=$OPTARG
            ;;
        a)
            ADDON_PACKAGE=$OPTARG
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done
./setup-tests.sh
echo "Running Acceptance Tests with Codeception..."
php ./vendor/bin/wpcept run
