#!/bin/sh

export $(grep -v '^#' .env | tr '\r' '\0' | xargs -d '\n')

echo "DROPPING Imported tabels...." 

echo "\n"

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/create_db/drop_all.sql > /dev/null

echo "\n"

echo "DROPPING Imported tabels DONE"

echo "\n"

echo "DROPPING functions and triggers..."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/create-triggers/drop_triggers.sql > /dev/null

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/search_functionality/drop_functions.sql > /dev/null

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/user_functions/drop.sql > /dev/null

echo "\n"

echo "DROPPING functions and triggers DONE"
