#!/usr/bin/env bash
## get some environment variables if they haven't been set yet.
if [ -z $WP_SITE_PATH ]; then
    set -o allexport
    source set-environment-variables.sh
    set +o allexport
fi

mkdir -p $SERVER_PATH

function install_wp_and_ee {
    echo "Creating WordPress test site..."
    rm -rf $WP_SITE_PATH
    mkdir $WP_SITE_PATH
    cd "$WP_SITE_PATH"
    cat > .gitignore << EOF
# Ignore all WP
/*
EOF
    wp core download --force
    wp core config --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASS" --extra-php <<PHP
    define( 'WP_DEBUG', true );
    define( 'WP_DEBUG_DISPLAY', false );
    define( 'WP_DEBUG_LOG', true );
PHP
    echo "Creating WordPress test database..."
    wp db drop -yes
    wp db create
    wp core install --url="$WP_SITE_URL" --title="Acceptance Testing Site" --admin_user="admin" --admin_password="admin" --admin_email="admin@example.com"

    ##Install EE core
    wp plugin install https://github.com/eventespresso/event-espresso-core --activate --force
}

#This takes care of copying any tests from the plugin for codeception tests
function install_codeception_tests_from_plugin {
    cp $WP_SITE_PATH/wp-content/plugins/event-espresso-core/acceptance_tests/* $PROJECT_ROOT/acceptance/
}


if [ ! -d "$WP_SITE_PATH/wp-admin" ]; then
    install_wp_and_ee
    install_codeception_tests_from_plugin
    cd $PROJECT_ROOT

    echo "Building Acceptance Tests with Codeception..."
    php ./vendor/bin/codecept build
fi