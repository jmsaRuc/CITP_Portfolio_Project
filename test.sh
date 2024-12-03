#!/bin/sh

export $(grep -v '^#' .env | tr '\r' '\0' | xargs -d '\n')


echo "Testing Database...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -f db/test/test.sql | tee db/test/test.log

echo "\n"

echo "Testing Database DONE"