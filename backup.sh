#!/bin/bash -e
SCRIPT_DIR=$( cd $(dirname $0) ; pwd -P )

source $SCRIPT_DIR/configure.sh

echo "==== Backuping DB..."
mysqldump -u root -proot $DB_NAME > sanpatrignano_db.sql
echo "==== Backuping images..."
cp -R $DOCUMENT_ROOT/$DOMAIN/wp-content/uploads  $SCRIPT_DIR/wordpress
