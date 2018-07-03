#!/bin/bash

PG_DUMPED_DATA_URL = ${PG_DUMPED_DATA_DEFAULT_URL}

if [ ! "$( psql -tAc "SELECT 1 FROM pg_database WHERE datname='${POSTGRES_DB}'" )" = '1' ]; then
    psql -tc "CREATE DATABASE ${POSTGRES_DB} WITH OWNER = ${POSTGRES_USER}"
fi

if [ ! -d "/usr/local/bin" ];then
    mkdir /usr/local/bin

if [ x"$1" = x ]; then
    echo "No data url specified, use default data url as below:"
    echo "${PG_DUMPED_DATA_URL}"
else
    PG_DUMPED_DATA_URL = $1
fi

echo "Download data from ${PG_DUMPED_DATA_URL} ..."
wget -O "/usr/local/bin/gtdb.sql" ${PG_DUMPED_DATA_URL}
sed -i "1s/^/\\\connect ${POSTGRES_DB}\n/" /usr/local/bin/gtdb.sql
chmod 755 /usr/local/bin/gtdb.sql \
echo "Import data ..."
psql -v gtdb_user=${POSTGRES_USER} -f /usr/local/bin/gtdb.sql
echo "Data imported into ${POSTGRES_DB}"
