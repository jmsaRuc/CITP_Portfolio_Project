FROM postgres:16.4 AS build
ENV PGTAP_VERSION='v1.3.3'

RUN apt-get update && \
    apt-get install -y build-essential git perl

RUN git clone https://github.com/theory/pgtap.git
WORKDIR /pgtap
RUN git checkout $PGTAP_VERSION

RUN make
RUN make install


FROM postgres:16.4
ENV DEST=/usr/share/postgresql/16/extension/
COPY --from=build $DEST $DEST

RUN mkdir -p /db/import_backup

RUN mkdir -p /db/script/create_db

RUN mkdir -p /db/script/create-triggers

RUN mkdir -p /db/script/search_functionality

RUN mkdir -p /db/test

COPY ./db/import_backup/imdb.backup /db/import_backup/imdb.backup 

COPY ./db/import_backup/omdb_data.backup /db/import_backup/omdb_data.backup

COPY ./db/import_backup/wi.backup /db/import_backup/wi.backup

COPY ./db/script/create_db/create_db_final.sql /db/script/create_db

COPY ./db/script/create-triggers/type-triggers.sql /db/script/create-triggers

COPY ./db/script/search_functionality/search_functions.sql /db/script/search_functionality

COPY ./db/test/test.sql /db/test

COPY ./init-db.sh /docker-entrypoint-initdb.d/init-db.sh

ENV OMGDB_POSTGRES_PORT=5432

ENV OMGDB_USERDATABASE=portf_1

ENV OMGDB_USER_PG=admin

ENV PGPASSWORD=admin

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["postgres"]