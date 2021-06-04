#!/bin/bash
set -euo pipefail
echo 'Warning: this action will remove the info-schema part of the '${HOCS_DB_NAME}' database. It cannot be undone!'

read -p 'Are you sure you want to remove the database (y/N)? ' yes_no

if [ $yes_no = 'y' -o $yes_no = 'Y' ];
then
    export PGPASSWORD=${HOCS_PASSWORD}
    export PGHOST=${HOCS_DB_HOSTNAME}
    export PGUSER=${HOCS_USERNAME}
    export PGDATABASE=${HOCS_DB_NAME}
    psql -c "DROP SCHEMA IF EXISTS info CASCADE"
else
    echo 'Aborted. No action was performed.' >&2
fi
