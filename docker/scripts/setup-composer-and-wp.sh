#!/usr/bin/env bash

# make sure /usr/local/bin is added to path.
PATH=$PATH:/usr/local/bin

## Install composer
cd /home/accuser
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
composer --version
## Install wp-cli
cd /home/accuser
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
wp --info