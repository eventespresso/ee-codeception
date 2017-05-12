#!/usr/bin/env bash
## get some environment variables if they haven't been set yet.
if [ -z $WP_SITE_PATH ]; then
    set -o allexport
    source set-environment-variables.sh
    set +o allexport
fi

mkdir -p $SERVER_PATH

WPCLIPATH=${PROJECT_ROOT}/vendor/bin/

parse_yaml() {
   local prefix=$2
    local s
    local w
    local fs
    s='[[:space:]]*'
    w='[a-zA-Z0-9_]*'
    fs="$(echo @|tr @ '\034')"
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
    awk -F"$fs" '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, $3);
        }
    }' | sed 's/_=/+=/g'
}

install_wp_and_ee() {
    echo "Creating WordPress test site..."
    rm -rf $WP_SITE_PATH
    mkdir $WP_SITE_PATH
    cd "$WP_SITE_PATH"
    sh ${WPCLIPATH}wp core download --force
    sh ${WPCLIPATH}wp core config --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASS" --extra-php <<PHP
    define( 'WP_DEBUG', true );
    define( 'WP_DEBUG_DISPLAY', false );
    define( 'WP_DEBUG_LOG', true );
PHP
    setupWPdb
    cd $WP_SITE_PATH
    ##Install EE core
    sh ${WPCLIPATH}wp plugin install https://github.com/eventespresso/event-espresso-core/archive/$EE_BRANCH.zip --force

    ##Install Add-on package if present
    if [ -n "$ADDON_PACKAGE" ]; then
        sh ${WPCLIPATH}wp plugin install https://github.com/eventespresso/${ADDON_PACKAGE}/archive/master.zip --force
    fi
}


## if we have ADDITIONAL_PLUGINS_TO_INSTALL defined then let's use wp-cli to install them.
install_additional_plugins() {
    cd $WP_SITE_PATH
    ## additional plugins instructed by core.
    if [ -f "${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/ee-codeception.yml" ]; then
        eval $(parse_yaml ${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/ee-codeception.yml)
        for plugin_slug in ${external_plugins[@]}; do
            sh ${WPCLIPATH}wp plugin install ${plugin_slug} --force
        done
    fi

    ##additional plugins instructed by the addon package (if present)
    if [ -n "$ADDON_PACKAGE" ]; then
        if [ -f "${WP_SITE_PATH}/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/ee-codeception.yml" ]; then
            eval $(parse_yaml ${WP_SITE_PATH}/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/ee-codeception.yml addon)
            for plugin_slug in ${addon_external_plugins[@]}; do
                sh ${WPCLIPATH}wp plugin install ${plugin_slug} --force
            done
        fi
    fi
    cd $PROJECT_ROOT
}

setupWPdb() {
    cd $WP_SITE_PATH
    echo "Creating WordPress test database..."
    sh ${WPCLIPATH}wp db drop --yes
    sh ${WPCLIPATH}wp db create
    sh ${WPCLIPATH}wp core install --url="$WP_SITE_URL" --title="Acceptance Testing Site" --admin_user="admin" --admin_password="admin" --admin_email="admin@example.com"
    cd $PROJECT_ROOT
}



#This takes care of copying any tests from the plugin for codeception tests
install_codeception_tests_from_plugin() {
    ## always copy PageObjects from EE core over if present
    if [ -d ${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/Page ]; then
        cp ${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/Page/* ${PROJECT_ROOT}/tests/_support/Page
    fi

    #any helper objects to copy for core?
    if [ -d ${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/Helpers ]; then
        cp ${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/Helpers/* ${PROJECT_ROOT}/src/helpers
    fi

    ## always call build_ee on core plugin if the yaml is present.
    if [ -f "${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/ee-codeception.yml" ]; then
        ${PROJECT_ROOT}/vendor/bin/codecept build_ee ${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/ee-codeception.yml
    fi

    # If addon package is present then only installing tests from addon package
    if [ -n "$ADDON_PACKAGE" ]; then
        cp ${WP_SITE_PATH}/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/tests/* ${PROJECT_ROOT}/tests/acceptance/
        ## any page objects to copy?
        if [ -d ${WP_SITE_PATH}/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/Page ]; then
            cp $WP_SITE_PATH/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/Page/* ${PROJECT_ROOT}/tests/_support/Page
        fi
        #any helper objects to copy?
        if [ -d ${WP_SITE_PATH}/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/Helpers ]; then
            cp $WP_SITE_PATH/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/Helpers/* ${PROJECT_ROOT}/src/helpers
        fi
        ## ee-codeception.yml present? This will be used for any build processing for the tests.
        if [ -f "${WP_SITE_PATH}/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/ee-codeception.yml" ]; then
            ${PROJECT_ROOT}/vendor/bin/codecept build_ee ${WP_SITE_PATH}/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/ee-codeception.yml
        fi
    # ...otherwise we install the core plugin tests
    else
        cp ${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/tests/* ${PROJECT_ROOT}/tests/acceptance/
    fi
}

## cleans out all items from previous test run.  Typically called when "start from scratch" is triggered.
clean_previous_test_items() {
    ## remove any existing helpers copied from previous tests
    echo -e "Removing all EE helpers from previous test.\n"
    find ${PROJECT_ROOT}/src/helpers -type f -not -name "AddonAggregate.php" -not -name "CoreAggregate.php" -print0 | xargs -0 rm -- 2> /dev/null

    ## remove any existing tests from previous runs
    echo -e "Removing all testcases from previous test.\n"
    find ${PROJECT_ROOT}/tests/acceptance -type f -not -name "_bootstrap.php" -print0 | xargs -0 rm -- 2> /dev/null

    ## remove any page objects from previous runs
    echo -e "Removing all page objects from previous test.\n"
    find ${PROJECT_ROOT}/tests/_support/Page -type f -not -name "Sample.php" -print0 | xargs -0 rm -- 2> /dev/null

    ## remove any artifacts
    echo -e "Removing all test artifacts from previous test.\n"
    find ${PROJECT_ROOT}/tests/_output -type f -not -name "index.php" -print0 | xargs -0 rm -- 2> /dev/null
}

if [ -n "$START_FROM_SCRATCH" ] || [ ! -d "${WP_SITE_PATH}/wp-admin" ]; then
    install_wp_and_ee
    clean_previous_test_items
    cd $PROJECT_ROOT

    echo "Building Acceptance Tests with Codeception..."
    vendor/bin/codecept build
    install_codeception_tests_from_plugin
    install_additional_plugins
fi
#we ALWAYS drop and recreate/install the db on repeated runs.  But if it's already been run
#then we leave alone.
if [ -z "$START_FROM_SCRATCH" ]; then
    setupWPdb
fi