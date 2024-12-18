#!/bin/sh

export $(grep -v '^#' .env | tr '\r' '\0' | xargs -d '\n')


echo "Importing title_ratings.sql from imdb.backup...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/import_backup/imdb.backup > /dev/null

echo "/n"

echo "Importing title_ratings.sql from imdb.backup DONE"

echo "/n"

echo "Creating a 1000 weighted dummy users....."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/test/create_dummy_users/create.sql > /dev/null

echo "/n"

echo "Creating a 1000 weighted dummy users DONE"

echo "/n"

echo "--------------------------------FINISHED IMPORTING DUMMY USERS"