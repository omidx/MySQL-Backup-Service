#!/bin/bash

# Directory paths for full and differential backups
FULL_BACKUP_DIR="/path/to/full_backups"
DIFF_BACKUP_DIR="/path/to/diff_backups"

# MySQL container name
MYSQL_CONTAINER_NAME="mysql_container"

# MySQL database connection information
MYSQL_USER="username"
MYSQL_PASSWORD="password"

# Function to create a full backup
create_full_backup() {
    timestamp=$(date +%Y%m%d_%H%M%S)
    full_backup_file="$FULL_BACKUP_DIR/full_backup_$timestamp.sql.gz"
    
    docker exec $MYSQL_CONTAINER_NAME mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD --all-databases | gzip > $full_backup_file

    echo "Full backup created: $full_backup_file"
}

# Function to create a differential backup
create_diff_backup() {
    timestamp=$(date +%Y%m%d_%H%M%S)
    diff_backup_file="$DIFF_BACKUP_DIR/diff_backup_$timestamp.sql.gz"
    
    last_full_backup=$(ls -t $FULL_BACKUP_DIR/full_backup_* | head -n 1)

    docker exec $MYSQL_CONTAINER_NAME mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD --all-databases --flush-logs --no-create-info --skip-triggers --skip-lock-tables --where="1 LIMIT 1000" | gzip > $diff_backup_file

    echo "Diff backup created: $diff_backup_file"
}

# Function to delete old backups
delete_old_backups() {
    # Delete backups older than 7 days
    find $FULL_BACKUP_DIR -type f -name "full_backup_*" -mtime +7 -exec rm {} \;
    find $DIFF_BACKUP_DIR -type f -name "diff_backup_*" -mtime +7 -exec rm {} \;

    echo "Old backups deleted"
}

# Run full backup every 12 hours
while true; do
    create_full_backup
    delete_old_backups
    sleep 43200 # 12 hours
done &

# Run differential backup every 1 hour
while true; do
    create_diff_backup
    delete_old_backups
    sleep 3600 # 1 hour
done &

wait # Wait for background jobs to finish
