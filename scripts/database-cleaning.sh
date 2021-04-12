#!/bin/bash
echo 'Warning: this action will completely remove the database '${HOCS_DB_NAME^^}' and all its contents. It cannot be undone!'

read -p 'Are you sure you want to remove the database (y/n)? ' yes_no

if [[ $yes_no = 'y' || $yes_no = 'Y' ]]
then
    export PGPASSWORD=${HOCS_PASSWORD}
    psql -h${HOCS_DB_HOSTNAME} -U${HOCS_USERNAME} -d${HOCS_DB_NAME} -c "DROP SCHEMA IF EXISTS info CASCADE"
    psql -h${HOCS_DB_HOSTNAME} -U${HOCS_USERNAME} -d${HOCS_DB_NAME} -c "DROP SCHEMA IF EXISTS casework CASCADE"
    psql -h${HOCS_DB_HOSTNAME} -U${HOCS_USERNAME} -d${HOCS_DB_NAME} -c "DROP SCHEMA IF EXISTS audit CASCADE"
    psql -h${HOCS_DB_HOSTNAME} -U${HOCS_USERNAME} -d${HOCS_DB_NAME} -c "DROP SCHEMA IF EXISTS document CASCADE"
    psql -h${HOCS_DB_HOSTNAME} -U${HOCS_USERNAME} -d${HOCS_DB_NAME} -c "DROP SCHEMA IF EXISTS workflow CASCADE"
    psql -h${HOCS_DB_HOSTNAME} -U${HOCS_USERNAME} -d${HOCS_DB_NAME} -c "CREATE SCHEMA workflow"
else
    echo 'Aborted, no action was performed.' >&2
fi
