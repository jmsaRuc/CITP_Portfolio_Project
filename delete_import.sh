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

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/user_functions/drop.sql > /dev/null

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/person_functions/drop.sql > /dev/null

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/genre_functions/drop.sql > /dev/null

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/series_functions/drop.sql > /dev/null

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/search_functionality/drop.sql > /dev/null

echo "\n"

echo "DROPPING functions and triggers DONE"

echo "\n"

echo "DROPPING indexes...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/create_indexs/drop.sql > /dev/null

echo "\n"

echo "DROPPING indexes DONE"

echo "\n"

echo "DROPPING Materialized_views...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/create_materialized_views/drop.sql > /dev/null

echo "\n"

echo "DROPPING Materialized_views DONE"

echo "\n"

echo "--------------------------------------DELETING IMPORTED DATABASE DONE"