DATE=$(date +%Y-%m-%d)
mysqldump -u root -proot sanpatrignano_db | gzip > sanpatrignano_db_$DATE.sql.gz
