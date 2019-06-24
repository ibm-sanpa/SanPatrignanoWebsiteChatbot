#!/bin/bash -e

# Website VPS configuration
DOMAIN="www.sanpa.org"
HOST_USER="webuser"
HOST_PASSWD="webpwd"
DOCUMENT_ROOT=/home/$HOST_USER/www
WP_CONFIG_FILE=$DOCUMENT_ROOT/$DOMAIN/wp-config.php
WP_CONTENT_FOLDER=$DOCUMENT_ROOT/$DOMAIN/wp-content

# Database configuration
DB_NAME="sanpatrignano_db"
DB_USER="dbuser"
DB_PASSWD="dbpwd"

# Wordpress configuration
WP_NAME="San Patrignano"
WP_DESCRIPTION="Il sito web della comunità di San Patrignano."
WP_USER="user"
WP_PASSWD="password"
WP_USER_EMAIL="user@gmail.com"
WP_NAME="San Patrignano"
WP_LOCALE="it_IT"
WP_THEME="dazzling"
WP_PLUGINS=""
