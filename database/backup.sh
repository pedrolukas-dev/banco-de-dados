#!/bin/bash
DB_USER="root"
DB_NAME="petvida"
DB_PORT="3307"
DATA=$(date +%Y-%m-%d_%H-%M-%S)
DIR_BACKUP="../backups"

mkdir -p $DIR_BACKUP

mysqldump -u $DB_USER -P $DB_PORT --databases $DB_NAME > "$DIR_BACKUP/petvida_$DATA.sql"