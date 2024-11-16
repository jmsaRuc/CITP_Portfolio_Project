echo "Creating the database...."

psql -p 5432 -U admin -d postgres -c "CREATE DATABASE $OMGDB_USERDATABASE;" > /dev/null

echo "Importing imdb.backup...." 

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -p 5432 -a -f /db/import_backup/imdb.backup > /dev/null

echo "Importing omdb_data.backup...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -p 5432 -a -f /db/import_backup/omdb_data.backup > /dev/null

echo "Importing wi.backup...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -p 5432 -a -f /db/import_backup/wi.backup > /dev/null

echo "\n"

echo "Importing base data DONE"

echo "\n"

echo "Creating the schema, moving data, and creating constraints........."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -p 5432 -a -f /db/script/create_db/create_db_final.sql > /dev/null


echo "\n"

echo "Importing base data to the schema DONE"

echo "\n"

echo "Importing triggers...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -p 5432 -a -f /db/script/create-triggers/type-triggers.sql > /dev/null

echo "\n"

echo "Importing triggers DONE"

echo "\n"

echo "Importing functions...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -p 5432 -a -f /db/script/search_functionality/search_functions.sql > /dev/null

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -p 5432 -a -f db/script/user_functions/create.sql > /dev/null

echo "\n"

echo "Importing functions DONE"

echo "Testing Database...."

PGUSER=$OMGDB_USER_PG PGDATABASE=$OMGDB_USERDATABASE psql -p 5432 -a -f /db/test/test.sql

echo "\n"

echo "Testing Database DONE"