#!/usr/bin/env bash
## get some environment variables if they haven't been set yet.
if [ -z $WP_SITE_PATH ]; then
    set -o allexport
    source set-environment-variables.sh
    set +o allexport
fi

mkdir -p $SERVER_PATH

install_wp_and_ee() {
    echo "Creating WordPress test site..."
    rm -rf $WP_SITE_PATH
    mkdir $WP_SITE_PATH
    cd "$WP_SITE_PATH"
    wp core download --force
    wp core config --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASS" --extra-php <<PHP
    define( 'WP_DEBUG', true );
    define( 'WP_DEBUG_DISPLAY', false );
    define( 'WP_DEBUG_LOG', true );
PHP
    ##Install EE core
    wp plugin install https://github.com/eventespresso/event-espresso-core/archive/$EE_BRANCH.zip --force

    ##Install Add-on package if present
    if [ -n "$ADDON_PACKAGE" ]; then
        wp plugin install https://github.com/eventespresso/$ADDON_PACKAGE/archive/master.zip --force
    fi
}


setupWPdb() {
    cd $WP_SITE_PATH
    echo "Creating WordPress test database..."
    wp db drop --yes
    wp db create
    wp core install --url="$WP_SITE_URL" --title="Acceptance Testing Site" --admin_user="admin" --admin_password="admin" --admin_email="admin@example.com"
}

#This takes care of copying any tests from the plugin for codeception tests
install_codeception_tests_from_plugin() {
    # If addon package is present then only installing tests from addon package
    if [ -n "$ADDON_PACKAGE" ]; then
        cp $WP_SITE_PATH/wp-content/plugins/$ADDON_PACKAGE/acceptance_tests/* $PROJECT_ROOT/acceptance/
    # ...otherwise we install the core plugin tests
    else
        cp $WP_SITE_PATH/wp-content/plugins/event-espresso-core/acceptance_tests/* $PROJECT_ROOT/acceptance/
    fi
}
if [ -n "$START_FROM_SCRATCH" ] || [ ! -d "$WP_SITE_PATH/wp-admin" ]; then
    install_wp_and_ee
    install_codeception_tests_from_plugin
    cd $PROJECT_ROOT

    echo "Building Acceptance Tests with Codeception..."
    php ./vendor/bin/codecept build
fi
#we ALWAYS drop and recreate/install the site on new runs
setupWPdb
cd $PROJECT_ROOT
