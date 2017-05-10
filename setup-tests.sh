#!/usr/bin/env bash
## get some environment variables if they haven't been set yet.
if [ -z $WP_SITE_PATH ]; then
    set -o allexport
    source set-environment-variables.sh
    set +o allexport
fi

mkdir -p $SERVER_PATH

WPCLIPATH=${PROJECT_ROOT}/vendor/bin/

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
    ##Install EE core
    sh ${WPCLIPATH}wp plugin install https://github.com/eventespresso/event-espresso-core/archive/$EE_BRANCH.zip --force

    ##Install Add-on package if present
    if [ -n "$ADDON_PACKAGE" ]; then
        sh ${WPCLIPATH}wp plugin install https://github.com/eventespresso/${ADDON_PACKAGE}/archive/master.zip --force
    fi
}


## if we have ADDITIONAL_PLUGINS_TO_INSTALL defined then let's use wp-cli to install them.
install_additional_plugins() {
    if [ -n ${ADDITIONAL_PLUGINS_TO_INSTALL} ]; then
        echo "Installing additional requested plugins"
        cd ${WP_SITE_PATH}

        for plugin_slug in ${ADDITIONAL_PLUGINS_TO_INSTALL[@]}; do
            sh ${WPCLIPATH}wp plugin install ${plugin_slug} --force
        done
    fi
}

setupWPdb() {
    cd $WP_SITE_PATH
    echo "Creating WordPress test database..."
    sh ${WPCLIPATH}wp db drop --yes
    sh ${WPCLIPATH}wp db create
    sh ${WPCLIPATH}wp core install --url="$WP_SITE_URL" --title="Acceptance Testing Site" --admin_user="admin" --admin_password="admin" --admin_email="admin@example.com"
}

#This takes care of copying any tests from the plugin for codeception tests
install_codeception_tests_from_plugin() {
    ## always copy PageObjects from EE core over if present
    if [ -d ${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/Page ]; then
        cp ${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/Page/* ${PROJECT_ROOT}/tests/_support/Page
    fi

    ## always call build_ee on core plugin if the yaml is present.
    if [ -f "${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/ee-codeception.yml" ]; then
        ${PROJECT_ROOT}/vendor/bin codecept build_ee ${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/ee-codeception.yml
    fi

    # If addon package is present then only installing tests from addon package
    if [ -n "$ADDON_PACKAGE" ]; then
        cp ${WP_SITE_PATH}/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/tests/* ${PROJECT_ROOT}/tests/acceptance/
        ## any page objects to copy?
        if [ -d ${WP_SITE_PATH}/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/Page ]; then
            cp $WP_SITE_PATH/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/Page/* ${PROJECT_ROOT}/tests/_support/Page
        fi
        ## ee-codeception.yml present? This will be used for any build processing for the tests.
        if [ -f "${WP_SITE_PATH}/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/ee-codeception.yml" ]; then
            ${PROJECT_ROOT}/vendor/bin codecept build_ee ${WP_SITE_PATH}/wp-content/plugins/${ADDON_PACKAGE}/acceptance_tests/ee-codeception.yml
        fi
    # ...otherwise we install the core plugin tests
    else
        cp ${WP_SITE_PATH}/wp-content/plugins/event-espresso-core/acceptance_tests/tests/* ${PROJECT_ROOT}/tests/acceptance/
    fi
}
if [ -n "$START_FROM_SCRATCH" ] || [ ! -d "${WP_SITE_PATH}/wp-admin" ]; then
    install_wp_and_ee
    install_codeception_tests_from_plugin
    cd $PROJECT_ROOT

    echo "Building Acceptance Tests with Codeception..."
    vendor/bin/codecept build
fi
#we ALWAYS drop and recreate/install the db on repeated runs.  But if it's already been run
#then we leave alone.
if [ -z "$START_FROM_SCRATCH" ]; then
    setupWPdb
    cd $PROJECT_ROOT
fi