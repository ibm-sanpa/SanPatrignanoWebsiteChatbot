#!/bin/bash -e
SCRIPT_DIR=$( cd $(dirname $0) ; pwd -P )
MYSQL_USER=root
MYSQL_PASSWD=root

source $SCRIPT_DIR/configure.sh

ENCRYPTED_PASSWD=$(openssl passwd -1 $HOST_PASSWD)


###################################################################
# create_account
#
# Input: none
# Description: this function creates the system account. The
#              account will have a HOME folder where there will
#              be the DocumentRoot=HOME/www and the website
#              will be installed in HOME/www/DOMAIN
# Return: none
###################################################################
create_account() {
    echo "==== configure $HOST_USER account"
    if [ "$(id -u $HOST_USER > /dev/null 2>&1; echo $?)" != "0" ]; then
        sudo useradd -d /home/$HOST_USER -g admin -s /bin/bash \
 		-p $ENCRYPTED_PASSWD $HOST_USER
    fi
    sudo mkdir -p $DOCUMENT_ROOT
    sudo chown -R $HOST_USER:admin /home/$HOST_USER
    sudo chown -R $HOST_USER:admin $DOCUMENT_ROOT
}

###################################################################
# download_wp
#
# Input: none
# Description: this function downloads, extracts, and configure  a
#              wordpress package.
# Return: none
###################################################################
download_wp() {
    echo "==== install wordpress in $DOCUMENT_ROOT/$DOMAIN"

    # Create new Document Root
    if [ -d "$DOCUMENT_ROOT/$DOMAIN" ]; then
        sudo rm -rf $DOCUMENT_ROOT/$DOMAIN
    fi
    sudo mkdir -p $DOCUMENT_ROOT/$DOMAIN
    sudo chown $HOST_USER:admin $DOCUMENT_ROOT/$DOMAIN

    # Download the WordPress core files and configure wp-config.php
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
	wp core download --locale=$WP_LOCALE; \
	wp config create --dbname=$DB_NAME --dbuser=$DB_USER \
		--dbpass=$DB_PASSWD --skip-check"
}

###################################################################
# create_db
#
# Input: none
# Description: this function creates an empty database and import
#              the data.
# Return: none
###################################################################
create_db() {
    echo "==== create database $DB_NAME"
    # Create MySQL user if does not exist
    DB_USER_EXIST="$(mysql -u $MYSQL_USER -p$MYSQL_PASSWD -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$DB_USER')")"

    if [ "$DB_USER_EXIST" != 1 ]; then
        mysql -u $MYSQL_USER -p$MYSQL_PASSWD -sse "CREATE USER $DB_USER@localhost IDENTIFIED BY \"$DB_PASSWD\";"
        mysql -u $MYSQL_USER -p$MYSQL_PASSWD -sse "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost;"
        mysql -u $MYSQL_USER -p$MYSQL_PASSWD -sse "FLUSH PRIVILEGES;"
    fi

    # Create database
    DB_NAME_EXIST="$(mysql -u $MYSQL_USER -p$MYSQL_PASSWD -sse "SELECT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$DB_NAME')")"

    if [ "$DB_NAME_EXIST" = "1" ]; then
        mysql -u $MYSQL_USER -p$MYSQL_PASSWD -sse "DROP database $DB_NAME;"
    fi
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
        wp db create --dbuser=$DB_USER --dbpass=$DB_PASSWD"
}

###################################################################
# install_wp
#
# Input: none
# Description: this function install Wordpress in the new database.
# Return: none
###################################################################
install_wp() {
    echo "==== install wordpress"
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
	wp core install --url=\"$DOMAIN\" \
	--title=\"$WP_NAME\" --admin_user=\"$WP_USER\" \
	--admin_password=\"$WP_PASSWD\" --admin_email=\"$WP_USER_EMAIL\""
}

###################################################################
# configure_wp_settings
#
# Input: none
# Description: this function configure Wordpress Settings menu pages.
# Return: none
###################################################################
configure_wp_settings() {
    echo "===== configure wordpress settings"

    # Modify Settings->General

    # Modify blog description
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
        wp option update blogdescription \"$WP_DESCRIPTION\""
    # Modify Settings->Reading
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
        wp option update posts_per_page 6"
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
        wp option update posts_per_rss 7"

    # Modify Settings->Discussions
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
       wp option update thread_comments 0"
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
       wp option update moderation_notify 0"
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
       wp option update comment_whitelist 0"
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
       wp option update show_avatars 0"

    # Modify Settings->Permalink
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
       wp rewrite structure '/%postname%.html' --hard"
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
       wp rewrite flush --hard"
}

###################################################################
# configure_wp_plugins
#
# Input: none
# Description: this function install and configure Wordpress plugins.
# Return: none
###################################################################
configure_wp_plugins() {
    echo "====== configure wordpress plugins"

    # Delete akismet and hello dolly plugins
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
       wp plugin delete akismet"
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
       wp plugin delete hello"

    # Install plugins
    export IFS=","
    for plugin in $WP_PLUGINS; do
        sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
            wp plugin install $plugin --activate"
    done

    # Enable direct FTP to install plugins from dashboard
    # Increase memory limit


}

###################################################################
# configure_wp_aspect
#
# Input: none
# Description: this function configure Wordpress aspects like
#              themes, menu, etc.
# Return: none
###################################################################
configure_wp_aspect() {
    echo "====== configure wordpress aspect"

    # Install the Theme
    sudo su - $HOST_USER -c "cd $DOCUMENT_ROOT/$DOMAIN; \
        wp theme install $WP_THEME --activate"
}

###################################################################
# configure_wp_config
#
# Input: none
# Description: this function configure direct FTP and memory limit
#              to install plugins from WP dashboard.
# Return: none
###################################################################
configure_wp_config() {

  echo "====== configure wordpress dashboard"
  echo "====== Append lines to wp-content.php file"

    cat >> $WP_CONFIG_FILE << EOL
  /**
  * Configure WP dashboard direct FTP and memory limit.
  */
  define('FS_METHOD', 'direct');
  define('WP_MEMORY_LIMIT', '3000M');

EOL
}

###################################################################
# configure_wa_config
#
# Input: none
# Description: this function configure WordPress WatsonConversation plugin.
# Return: none
###################################################################
configure_wa_plugin() {

 ASSISTANT_URL=""
 ASSISTANT_USERNAME=""
 ASSISTANT_PASSWORD=""

 echo "====== configure watson conversation plugin"

 if [ -e "$SCRIPT_DIR/.env" ]; then
     source $SCRIPT_DIR/.env
 fi

 sed -i -e "s#ASSISTANT_URL#${ASSISTANT_URL}#g" ${SCRIPT_DIR}/${DB_NAME}.sql
 sed -i -e "s/ASSISTANT_USERNAME/${ASSISTANT_USERNAME}/g" ${SCRIPT_DIR}/${DB_NAME}.sql
 sed -i -e "s/ASSISTANT_PASSWORD/${ASSISTANT_PASSWORD}/g" ${SCRIPT_DIR}/${DB_NAME}.sql

}

###################################################################
# configure_wp
#
# Input: none
# Description: this function configure Wordpress.
# Return: none
###################################################################
configure_wp() {

    echo "==== configure wordpress"

    # Modify Settings configuration
    configure_wp_settings

    # Install and configure Wordpress plugins
    configure_wp_plugins
    configure_wa_plugin

    # Configure Wordpress aspect
    configure_wp_aspect

    # Configure Wordpress dashboard
    configure_wp_config

}

###################################################################
# import:_wp
#
# Input: none
# Description: this function import WordPress db and site images
# Return: none
###################################################################
import_wp() {

  echo "===== Import wordpress databsase"
  mysql -u $MYSQL_USER -p$MYSQL_PASSWD $DB_NAME < $SCRIPT_DIR/$DB_NAME.sql

  echo "===== Import wordpress images "
  cp -R $SCRIPT_DIR/wordpress/uploads $DOCUMENT_ROOT/$DOMAIN/wp-content

  echo "===== Change file permission on wp-content wordpress folder"
  chown -R www-data:www-data $WP_CONTENT_FOLDER

}


###################################################################
# configure_nginx
#
# Input: none
# Description: this function configure nginx adding the new website.
# Return: none
###################################################################
configure_nginx() {
    echo "====== configure nginx"
    # Configure NGINX
    sed "s:DOCUMENT_ROOT:$DOCUMENT_ROOT:g" /vagrant/nginx/site > /vagrant/tmp/site
    sed -i "s:DOMAIN:$DOMAIN:g" /vagrant/tmp/site
    sudo cp /vagrant/tmp/site /etc/nginx/sites-available/$DOMAIN
    sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN
    sudo service nginx restart
}

###################################################################
# main
#
# Input: none
# Description: the main procedure
# Return: none
###################################################################
main() {
    echo "================================================================="
    echo "Awesome WordPress Installer!!"
    echo "================================================================="
    mkdir -p /vagrant/tmp
    create_account
    download_wp
    create_db
    install_wp
    configure_wp
    import_wp
    configure_nginx
    rm -rf /vagrant/tmp
    echo "================================================================="
    echo "Installation is complete."
    echo "================================================================="
}

###################################################################
# Main block
###################################################################
main
