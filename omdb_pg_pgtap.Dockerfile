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

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["postgres"]