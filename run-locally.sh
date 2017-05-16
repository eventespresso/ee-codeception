#!/usr/bin/env bash
usage() {
    echo "\n\n\tusage: sh run-locally.sh [ -h This usage instructions ] [ -s start from scratch ] [ -b ee-branch ] [ -t ee-core-tag ] [ -a ee-addon-package-slug ]"
    echo "\texample: To run tests with ee core branch 'FET-12345-some-work'"
    echo "\tsh run-locally.sh -b FET-12345-some-work\n\n"
    exit 2
}

while getopts "hsb:t:a:f:" opt; do
    case ${opt} in
        h)
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
        s)
            export START_FROM_SCRATCH=true
            ;;
        f)
            export FILES=${OPTARG}
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

##make sure webservers are started
./server-services start

source setup-tests.sh
echo "Running Acceptance Tests with Codeception..."
if [ -n "$FILES" ]; then
    php ./vendor/bin/wpcept run acceptance ${FILES} --steps
else
    php ./vendor/bin/wpcept run --steps
fi
## stop webservers
./server-services stop
