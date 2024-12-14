#!/bin/sh

export $(grep -v '^#' .env | tr '\r' '\0' | xargs -d '\n')

# Importing the backup of the database

echo "Importing imdb.backup...." 

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/import_backup/imdb.backup > /dev/null

echo "Importing omdb_data.backup...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/import_backup/omdb_data.backup > /dev/null

echo "Importing wi.backup...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/import_backup/wi.backup > /dev/null

echo "\n"

echo "Importing base data DONE"

echo "\n"

echo "Creating the schema, moving data, and creating constraints........."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/create_db/create_db_final.sql > /dev/null


echo "\n"

echo "Importing base data to the schema DONE"

echo "\n"

echo "Importing Materialized_views...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/create_materialized_views/create.sql > /dev/null

echo "\n"

echo "Importing Materialized_views DONE"

echo "\n"

echo "Importing triggers...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/create-triggers/type-triggers.sql > /dev/null

echo "\n"

echo "Importing triggers DONE"

echo "\n"

echo "Importing functions...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/search_functionality/search_functions.sql > /dev/null

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/user_functions/create.sql > /dev/null

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/person_functions/create.sql > /dev/null

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/genre_functions/create.sql > /dev/null


echo "\n"

echo "Importing functions DONE"

echo "\n"

echo "Importing indexes...." 

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -h $OMGDB_POSTGRES_HOST -p $OMGDB_POSTGRES_PORT -a -f db/script/create_indexs/create.sql > /dev/null

echo "\n"

echo "Importing indexes DONE"

echo "\n"

echo "-----------FINISHED IMPORTING DATABASE"
