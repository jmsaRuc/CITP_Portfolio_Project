-- Active: 1727253378954@@127.0.0.1@5532@portf_1

CREATE SCHEMA IF NOT EXISTS pgtap;

SET search_path TO public, pgtap;

CREATE EXTENSION IF NOT EXISTS pgtap SCHEMA pgtap VERSION "1.3.3" CASCADE;

CREATE SEQUENCE IF NOT EXISTS public.title_seq INCREMENT BY 1 NO MINVALUE NO MAXVALUE;

CREATE SEQUENCE IF NOT EXISTS public.user_seq 
START WITH 1 
INCREMENT BY 1 
NO MINVALUE 
NO MAXVALUE;

CREATE SEQUENCE IF NOT EXISTS public.person_seq INCREMENT BY 1 NO MINVALUE NO MAXVALUE;

CREATE SEQUENCE IF NOT EXISTS public.watchlist_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE;

CREATE TABLE IF NOT EXISTS public.movie (
    movie_id character varying(10) NOT NULL DEFAULT 'tt' || to_char(
        nextval('public.title_seq'::regclass),
        'FM00000000'
    ),
    title character varying(256) NOT NULL,
    re_year character varying(4),
    run_time character varying(80),
    poster character varying(180),
    plot TEXT,
    release_date date,
    average_rating numeric(5, 1),
    CONSTRAINT average_rating_check CHECK ((average_rating > (0)::numeric)),
    imdb_rating numeric(5, 1),
    CONSTRAINT imdb_rating_check CHECK ((imdb_rating > (0)::numeric)),
    popularity BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT popularity_check CHECK ((popularity >= (0)::BIGINT))
);

CREATE TABLE IF NOT EXISTS public.episode (
    episode_id character varying(10) NOT NULL DEFAULT 'tt' || to_char(
        nextval('public.title_seq'::regclass),
        'FM00000000'
    ),
    title character varying(256) NOT NULL,
    re_year character varying(4),
    run_time character varying(80),
    poster character varying(180),
    plot TEXT,
    relese_date date,
    average_rating numeric(5, 1),
    CONSTRAINT average_rating_check CHECK ((average_rating > (0)::numeric)),
    imdb_rating numeric(5, 1),
    CONSTRAINT imdb_rating_check CHECK ((imdb_rating > (0)::numeric)),
    popularity BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT popularity_check CHECK ((popularity >= (0)::BIGINT))
);

CREATE TABLE IF NOT EXISTS public.series (
    series_id character varying(10) NOT NULL DEFAULT 'tt' || to_char(
        nextval('public.title_seq'::regclass),
        'FM00000000'
    ),
    title character varying(256) NOT NULL,
    start_year character varying(4),
    end_year character varying(4),
    poster character varying(180),
    plot TEXT,
    average_rating numeric(5, 1),
    CONSTRAINT average_rating_check CHECK ((average_rating > (0)::numeric)),
    imdb_rating numeric(5, 1),
    CONSTRAINT imdb_rating_check CHECK ((imdb_rating > (0)::numeric)),
    popularity BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT popularity_check CHECK ((popularity >= (0)::BIGINT))
);


CREATE TABLE IF NOT EXISTS public.user (
    user_id character varying(10) NOT NULL DEFAULT 'ur' || to_char(
    nextval('public.user_seq'::regclass),
    'FM00000000'
),
    username character varying(256) NOT NULL,
    PASSWORD bytea NOT NULL,
    salt bytea NOT NULL,
    email character varying(256) NOT NULL UNIQUE,
    created_at date NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS public.person (
    person_id character varying(10) NOT NULL DEFAULT 'nm' || to_char(
    nextval('public.person_seq'::regclass),
    'FM00000000'
    ),
    name character varying(256) NOT NULL,
    birth_year character(4),
    death_year character(4),
    primary_profession character varying(256),
    popularity BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT popularity_check CHECK ((popularity >= (0)::BIGINT))
);

CREATE TABLE IF NOT EXISTS public.user_movie_watchlist (
    user_id character varying(10) NOT NULL,
    movie_id character varying(10) NOT NULL,
    watchlist BIGINT NOT NULL DEFAULT nextval('public.watchlist_seq'::regclass),
    CONSTRAINT watchlist_check CHECK ((watchlist > (0)::BIGINT))
);

CREATE TABLE IF NOT EXISTS public.user_series_watchlist (
    user_id character varying(10) NOT NULL,
    series_id character varying(10) NOT NULL,
    watchlist BIGINT NOT NULL DEFAULT nextval('public.watchlist_seq'::regclass),
    CONSTRAINT watchlist_check CHECK ((watchlist > (0)::BIGINT))
);

CREATE TABLE IF NOT EXISTS public.user_episode_watchlist (
    user_id character varying(10) NOT NULL,
    episode_id character varying(10) NOT NULL,
    watchlist BIGINT NOT NULL DEFAULT nextval('public.watchlist_seq'::regclass),
    CONSTRAINT watchlist_check CHECK ((watchlist > (0)::BIGINT))
);
CREATE TABLE IF NOT EXISTS public.user_movie_rating (
    user_id character varying(10) NOT NULL,
    movie_id character varying(10) NOT NULL,
    rating smallint,
    CONSTRAINT rating_check CHECK (rating BETWEEN 1 AND 10)
);

CREATE TABLE IF NOT EXISTS public.user_series_rating (
    user_id character varying(10) NOT NULL,
    series_id character varying(10),
    rating smallint,
    CONSTRAINT rating_check CHECK (rating BETWEEN 1 AND 10)
);

CREATE TABLE IF NOT EXISTS public.user_episode_rating (
    user_id character varying(10) NOT NULL,
    episode_id character varying(10),
    rating smallint,
    CONSTRAINT rating_check CHECK (rating BETWEEN 1 AND 10)
);

CREATE TABLE IF NOT EXISTS Public.movie_language (
    LANGUAGE character varying(200),
    movie_id character varying(10)
);

CREATE TABLE IF NOT EXISTS public.series_language (
    LANGUAGE character varying(200),
    series_id character varying(10)
);

CREATE TABLE IF NOT EXISTS public.episode_language (
    LANGUAGE character varying(200),
    episode_id character varying(10)
);

CREATE TABLE IF NOT EXISTS public.is_in_movie (
    person_id character varying(10) NOT NULL,
    movie_id character varying(10),
    cast_order BIGINT,
    CONSTRAINT order_check CHECK ((cast_order > (0)::BIGINT)),
    ROLE character varying(50),
    job TEXT,
    character TEXT
);

CREATE TABLE IF NOT EXISTS public.is_in_series (
    person_id character varying(10) NOT NULL,
    series_id character varying(10),
    cast_order BIGINT,
    CONSTRAINT order_check CHECK ((cast_order > (0)::BIGINT)),
    ROLE character varying(50),
    job TEXT,
    character TEXT
);

CREATE TABLE IF NOT EXISTS public.is_in_episode (
    person_id character varying(10) NOT NULL,
    episode_id character varying(10),
    cast_order BIGINT,
    CONSTRAINT order_check CHECK ((cast_order > (0)::BIGINT)),
    ROLE character varying(50),
    job TEXT,
    character TEXT
);

CREATE TABLE IF NOT EXISTS public.movie_genre (
    genre_name character varying(256) NOT NULL,
    movie_id character varying(10)
);

CREATE TABLE IF NOT EXISTS public.series_genre (
    genre_name character varying(256) NOT NULL,
    series_id character varying(10)
);

CREATE TABLE IF NOT EXISTS public.episode_genre (
    genre_name character varying(256) NOT NULL,
    episode_id character varying(10)
);

CREATE TABLE IF NOT EXISTS public.movie_keywords (
    movie_id character varying(10),
    word TEXT NOT NULL,
    field character varying(1) NOT NULL,
    lexeme TEXT
);

CREATE TABLE IF NOT EXISTS public.series_keywords (
    series_id character varying(10),
    word TEXT NOT NULL,
    field character varying(1) NOT NULL,
    lexeme TEXT
);

CREATE TABLE IF NOT EXISTS public.episode_keywords (
    episode_id character varying(10),
    word TEXT NOT NULL,
    field character varying(1) NOT NULL,
    lexeme TEXT
);

CREATE TABLE IF NOT EXISTS public.person_keywords (
    person_id character varying(10),
    word TEXT NOT NULL,
    field character varying(1) NOT NULL,
    lexeme TEXT
);

CREATE TABLE IF NOT EXISTS public.episode_series (
    series_id character varying(10),
    episode_id character varying(10),
    season_number BIGINT,
    CONSTRAINT season_number_check CHECK (
        (season_number > (0)::BIGINT)
    ),
    episode_number BIGINT,
    CONSTRAINT episode_number_check CHECK (
        (
            episode_number >= (0)::BIGINT
        )
    )
);

CREATE TABLE IF NOT EXISTS public.recent_view (
    user_id character varying(10) NOT NULL,
    type_id character varying(10) NOT NULL,
    view_ordering bigint GENERATED ALWAYS AS IDENTITY,
    CONSTRAINT view_ordering CHECK (
        (view_ordering > (0)::bigint)
    )
);

CREATE TABLE IF NOT EXISTS public.type (
    type_id character varying(10) NOT NULL,
    title_type character varying(10) NOT NULL,
    CONSTRAINT title_type_check CHECK (
        title_type IN (
            'movie',
            'series',
            'episode',
            'person'
        )
    )
);

-- movie import part 1
INSERT INTO
    movie (movie_id, title, re_year)
SELECT tconst, primarytitle, startyear
FROM public.title_basics
WHERE
    titletype != 'tvEpisode'
    AND titletype != 'tvMiniSeries'
    AND titletype != 'tvSeries'
    AND titletype != 'videoGame';

--movie import part 2¨
--

WITH
    not_an_epi AS (
        SELECT movie_id AS not_id
        FROM movie
    ),
    date_not_na AS (
        SELECT
            tconst AS _id,
            released,
            CASE
                WHEN released = 'N/A' THEN NULL
                ELSE TO_DATE(released, 'DD Mon YYYY')
            END AS release_date
        FROM omdb_data
    )
UPDATE movie
SET
    run_time = runtime,
    poster = omdb_data.poster,
    plot = omdb_data.plot,
    release_date = date_not_na.release_date
FROM
    omdb_data,
    not_an_epi,
    date_not_na
WHERE
    tconst = not_an_epi.not_id
    AND tconst = date_not_na._id
    AND tconst = movie_id;

-- movie import part 3
UPDATE movie
SET
    imdb_rating = averagerating
FROM title_ratings
WHERE
    movie_id = tconst;

-- series import part 1
INSERT INTO
    series (
        series_id,
        title,
        start_year,
        end_year
    )
SELECT
    tconst,
    primarytitle,
    startyear,
    endyear
FROM title_basics
WHERE
    titletype = 'tvMiniSeries'
    OR titletype = 'tvSeries';

-- series import part 2

WITH
    an_seris AS (
        SELECT series_id AS not_id
        FROM series
    )
UPDATE series
SET
    poster = omdb_data.poster,
    plot = omdb_data.plot
FROM omdb_data, an_seris
WHERE
    tconst = an_seris.not_id
    AND tconst = series_id;

-- series import part 3
UPDATE series
SET
    imdb_rating = averagerating
FROM title_ratings
WHERE
    series_id = tconst;

-- episode import part 1
INSERT INTO
    episode (episode_id, title, re_year)
SELECT tconst, primarytitle, startyear
FROM title_basics
WHERE
    titletype = 'tvEpisode';

-- episode import part 2
WITH
    an_epi AS (
        SELECT episode_id AS not_id
        FROM episode
    ),
    date_not_na AS (
        SELECT
            tconst AS _id,
            released,
            CASE
                WHEN released = 'N/A' THEN NULL
                ELSE TO_DATE(released, 'DD Mon YYYY')
            END AS release_date
        FROM omdb_data
    )
UPDATE episode
SET
    run_time = runtime,
    poster = omdb_data.poster,
    plot = omdb_data.plot,
    relese_date = date_not_na.release_date
FROM omdb_data, an_epi, date_not_na
WHERE
    tconst = an_epi.not_id
    AND tconst = date_not_na._id
    AND tconst = episode_id;

-- episode import part 3
UPDATE episode
SET
    imdb_rating = averagerating
FROM title_ratings
WHERE
    episode_id = tconst;

-- import series episodes relation part 1
INSERT INTO
    episode_series (
        series_id,
        episode_id,
        season_number,
        episode_number
    )
SELECT
    parenttconst,
    tconst,
    seasonnumber,
    episodenumber
FROM title_episode;
-- import person part 1
INSERT INTO
    person (
        person_id,
        name,
        birth_year,
        death_year,
        primary_profession
    )
SELECT
    nconst,
    primaryname,
    birthyear,
    deathyear,
    split_part(primaryprofession, ',', 1) AS primary_profession
FROM name_basics;

-- movie_genre
INSERT INTO
    movie_genre (genre_name, movie_id)
SELECT string_to_table(genres, ',') AS genre, tconst
FROM title_basics
WHERE
    genres IS NOT NULL
    AND titletype != 'tvEpisode'
    AND titletype != 'tvMiniSeries'
    AND titletype != 'tvSeries'
    AND titletype != 'videoGame';

-- series_genre
INSERT INTO
    series_genre (genre_name, series_id)
SELECT string_to_table(genres, ',') AS genre, tconst
FROM title_basics
WHERE
    genres IS NOT NULL
    AND titletype = 'tvMiniSeries'
    OR titletype = 'tvSeries';

-- episode_genre
INSERT INTO
    episode_genre (genre_name, episode_id)
SELECT string_to_table(genres, ',') AS genre, tconst
FROM title_basics
WHERE
    genres IS NOT NULL
    AND titletype = 'tvEpisode';

-- is_in_movie
INSERT INTO
    is_in_movie (
        person_id,
        movie_id,
        cast_order,
        ROLE,
        job,
        character
    )
WITH
    titletype_movie AS (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype != 'tvEpisode'
            AND titletype != 'tvMiniSeries'
            AND titletype != 'tvSeries'
            AND titletype != 'videoGame'
    )
SELECT
    nconst,
    tconst,
    ordering,
    category,
    job,
    characters
FROM
    title_principals
    NATURAL JOIN titletype_movie;

-- is_in_series
INSERT INTO
    is_in_series (
        person_id,
        series_id,
        cast_order,
        ROLE,
        job,
        character
    )
WITH
    titletype_series AS (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvMiniSeries'
            OR titletype = 'tvSeries'
    )
SELECT
    nconst,
    tconst,
    ordering,
    category,
    job,
    characters
FROM
    title_principals
    NATURAL JOIN titletype_series;

-- is_in_episode

INSERT INTO
    is_in_episode (
        person_id,
        episode_id,
        cast_order,
        ROLE,
        job,
        character
    )
WITH
    titletype_episode AS (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvEpisode'
    )
SELECT
    nconst,
    tconst,
    ordering,
    category,
    job,
    characters
FROM
    title_principals
    NATURAL JOIN titletype_episode;

-- movie_keywords

INSERT INTO
    movie_keywords (movie_id, word, field, lexeme)
WITH
    titletype_episode AS (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype != 'tvEpisode'
            AND titletype != 'tvMiniSeries'
            AND titletype != 'tvSeries'
            AND titletype != 'videoGame'
    )
SELECT wi.tconst, word, field, lexeme
FROM wi
    NATURAL JOIN titletype_episode;

-- series_keywords
INSERT INTO
    series_keywords (
        series_id,
        word,
        field,
        lexeme
    )
WITH
    titletype_series AS (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvMiniSeries'
            OR titletype = 'tvSeries'
    )
SELECT wi.tconst, word, field, lexeme
FROM wi
    NATURAL JOIN titletype_series;

-- episode_keywords
INSERT INTO
    episode_keywords (
        episode_id,
        word,
        field,
        lexeme
    )
WITH
    titletype_episode AS (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvEpisode'
    )
SELECT wi.tconst, word, field, lexeme
FROM wi
    NATURAL JOIN titletype_episode;

-- movie_language
INSERT INTO
    movie_language (LANGUAGE, movie_id)
WITH
    titletype_movie AS (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype != 'tvEpisode'
            AND titletype != 'tvMiniSeries'
            AND titletype != 'tvSeries'
            AND titletype != 'videoGame'
    )
SELECT string_to_table(LANGUAGE, ','), tconst
FROM omdb_data
    NATURAL JOIN titletype_movie
WHERE
    tconst != 'tt3795628';

INSERT INTO
    movie_language (LANGUAGE, movie_id)
VALUES ('English', 'tt3795628');
-- series_language
INSERT INTO
    series_language (LANGUAGE, series_id)
WITH
    titletype_series AS (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvMiniSeries'
            OR titletype = 'tvSeries'
    )
SELECT string_to_table(LANGUAGE, ','), omdb_data.tconst
FROM omdb_data, titletype_series
WHERE
    omdb_data.tconst = titletype_series.tconst;

-- episode_language
INSERT INTO
    episode_language (LANGUAGE, episode_id)
WITH
    titletype_episode AS (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvEpisode'
    )
SELECT string_to_table(LANGUAGE, ','), omdb_data.tconst
FROM omdb_data, titletype_episode
WHERE
    omdb_data.tconst = titletype_episode.tconst;

-- import type

INSERT INTO
    public.type (type_id, title_type)
WITH
    type_change AS (
        SELECT
            tconst,
            titletype,
            CASE
                WHEN titletype = 'tvEpisode' THEN 'episode'
                WHEN titletype = 'tvMiniSeries' THEN 'series'
                WHEN titletype = 'tvSeries' THEN 'series'
                WHEN titletype = 'videoGame' THEN NULL
                ELSE 'movie'
            END AS type_name_v
        FROM title_basics
    )
SELECT tconst, type_change.type_name_v
FROM type_change
WHERE
    type_change.type_name_v IS NOT NULL;

-- import person type

INSERT INTO
    public.type (type_id, title_type)
SELECT person_id, 'person'
FROM person;

ALTER TABLE IF EXISTS public.movie
ADD CONSTRAINT movie_pkey PRIMARY KEY (movie_id);

ALTER TABLE IF EXISTS public.type
ADD CONSTRAINT type_pkey PRIMARY KEY (type_id);

ALTER TABLE IF EXISTS public.user_movie_watchlist
ADD CONSTRAINT user_movie_watchlist_pkey PRIMARY KEY (user_id, movie_id);

ALTER TABLE IF EXISTS public.user_series_watchlist
ADD CONSTRAINT user_series_watchlist_pkey PRIMARY KEY (user_id, series_id);

ALTER TABLE IF EXISTS public.user_episode_watchlist
ADD CONSTRAINT user_episode_watchlist_pkey PRIMARY KEY (user_id, episode_id);

ALTER TABLE IF EXISTS public.user_movie_rating
ADD CONSTRAINT user_movie_rating_pkey PRIMARY KEY (user_id, movie_id);

ALTER TABLE IF EXISTS public.user_series_rating
ADD CONSTRAINT user_series_rating_pkey PRIMARY KEY (user_id, series_id);

ALTER TABLE IF EXISTS public.user_episode_rating
ADD CONSTRAINT user_episode_rating_pkey PRIMARY KEY (user_id, episode_id);

ALTER TABLE IF EXISTS public.movie_language
ADD CONSTRAINT movie_language_pkey PRIMARY KEY (LANGUAGE, movie_id);

ALTER TABLE IF EXISTS public.series_language
ADD CONSTRAINT series_language_pkey PRIMARY KEY (LANGUAGE, series_id);

ALTER TABLE IF EXISTS public.episode_language
ADD CONSTRAINT episode_language_pkey PRIMARY KEY (LANGUAGE, episode_id);

ALTER TABLE IF EXISTS public.is_in_movie
ADD CONSTRAINT is_in_movie_pkey PRIMARY KEY (
    person_id,
    movie_id,
    cast_order
);

ALTER TABLE IF EXISTS public.is_in_series
ADD CONSTRAINT is_in_series_pkey PRIMARY KEY (
    person_id,
    series_id,
    cast_order
);

ALTER TABLE IF EXISTS public.is_in_episode
ADD CONSTRAINT is_in_episode_pkey PRIMARY KEY (
    person_id,
    episode_id,
    cast_order
);

ALTER TABLE IF EXISTS public.movie_genre
ADD CONSTRAINT movie_genre_pkey PRIMARY KEY (genre_name, movie_id);

ALTER TABLE IF EXISTS public.series_genre
ADD CONSTRAINT series_genre_pkey PRIMARY KEY (genre_name, series_id);

ALTER TABLE IF EXISTS public.episode_genre
ADD CONSTRAINT episode_genre_pkey PRIMARY KEY (genre_name, episode_id);

ALTER TABLE IF EXISTS public.movie_keywords
ADD CONSTRAINT movie_keywords_pkey PRIMARY KEY (movie_id, word, field);

ALTER TABLE IF EXISTS public.series_keywords
ADD CONSTRAINT series_keywords_pkey PRIMARY KEY (series_id, word, field);

ALTER TABLE IF EXISTS public.episode_keywords
ADD CONSTRAINT episode_keywords_pkey PRIMARY KEY (episode_id, word, field);

ALTER TABLE IF EXISTS public.person_keywords
ADD CONSTRAINT person_keywords_pkey PRIMARY KEY (person_id, word, field);

ALTER TABLE IF EXISTS public.person
ADD CONSTRAINT person_pkey PRIMARY KEY (person_id);

ALTER TABLE IF EXISTS public.episode
ADD CONSTRAINT episode_pkey PRIMARY KEY (episode_id);

ALTER TABLE IF EXISTS public.episode_series
ADD CONSTRAINT episode_series_pkey PRIMARY KEY (series_id, episode_id);

ALTER TABLE IF EXISTS public.series
ADD CONSTRAINT series_pkey PRIMARY KEY (series_id);

ALTER TABLE IF EXISTS public.user
ADD CONSTRAINT user_pkey PRIMARY KEY (user_id);

ALTER TABLE IF EXISTS public.recent_view
ADD CONSTRAINT recent_view_pkey PRIMARY KEY (user_id, type_id);

ALTER TABLE IF EXISTS public.user_movie_watchlist
ADD CONSTRAINT user_movie_watchlist_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user (user_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_series_watchlist
ADD CONSTRAINT user_series_watchlist_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user (user_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_episode_watchlist
ADD CONSTRAINT user_episode_watchlist_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user (user_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_movie_watchlist
ADD CONSTRAINT user_movie_watchlist_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie (movie_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_series_watchlist
ADD CONSTRAINT user_series_watchlist_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series (series_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_episode_watchlist
ADD CONSTRAINT user_episode_watchlist_episode_id_fkey FOREIGN KEY (episode_id) REFERENCES public.episode (episode_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_movie_rating
ADD CONSTRAINT user_movie_rating_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user (user_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_movie_rating
ADD CONSTRAINT user_movie_rating_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie (movie_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_series_rating
ADD CONSTRAINT user_series_rating_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user (user_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_series_rating
ADD CONSTRAINT user_series_rating_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series (series_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_episode_rating
ADD CONSTRAINT user_episode_rating_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user (user_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_episode_rating
ADD CONSTRAINT user_episode_rating_episode_id_fkey FOREIGN KEY (episode_id) REFERENCES public.episode (episode_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.movie_language
ADD CONSTRAINT movie_language_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie (movie_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.series_language
ADD CONSTRAINT series_language_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series (series_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.episode_language
ADD CONSTRAINT episode_language_episode_id_fkey FOREIGN KEY (episode_id) REFERENCES public.episode (episode_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.is_in_movie
ADD CONSTRAINT is_in_movie_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie (movie_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.is_in_series
ADD CONSTRAINT is_in_series_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series (series_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.is_in_episode
ADD CONSTRAINT is_in_episode_episode_id_fkey FOREIGN KEY (episode_id) REFERENCES public.episode (episode_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.movie_genre
ADD CONSTRAINT movie_genre_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie (movie_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.series_genre
ADD CONSTRAINT series_genre_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series (series_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.episode_genre
ADD CONSTRAINT episode_genre_episode_id_fkey FOREIGN KEY (episode_id) REFERENCES public.episode (episode_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.movie_keywords
ADD CONSTRAINT movie_keywords_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie (movie_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.series_keywords
ADD CONSTRAINT series_keywords_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series (series_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.episode_keywords
ADD CONSTRAINT episode_keywords_episode_id_fkey FOREIGN KEY (episode_id) REFERENCES public.episode (episode_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.episode_series
ADD CONSTRAINT episode_series_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series (series_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.episode_series
ADD CONSTRAINT episode_series_episode_id_fkey FOREIGN KEY (episode_id) REFERENCES public.episode (episode_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.recent_view
ADD CONSTRAINT recent_view_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.type (type_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.recent_view
ADD CONSTRAINT recent_view_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user (user_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.is_in_movie
ADD CONSTRAINT is_in_movie_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person (person_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.is_in_series
ADD CONSTRAINT is_in_series_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person (person_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.is_in_episode
ADD CONSTRAINT is_in_episode_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person (person_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.person_keywords
ADD CONSTRAINT person_keywords_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person (person_id) ON UPDATE CASCADE ON DELETE CASCADE;

SELECT SETVAL('public.title_seq',(SELECT RIGHT(max("type_id"), 7) max_val FROM public."type")::bigint);


SELECT SETVAL('public.person_seq',(SELECT RIGHT(max("person_id"), 7) max_val FROM public."person")::bigint);

DROP TABLE IF EXISTS public.title_basics;

DROP TABLE IF EXISTS public.title_episode;

DROP TABLE IF EXISTS public.title_principals;

DROP TABLE IF EXISTS public.title_ratings;

DROP TABLE IF EXISTS public.omdb_data;

DROP TABLE IF EXISTS public.name_basics;

DROP TABLE IF EXISTS public.wi;

DROP TABLE IF EXISTS public.title_akas;

DROP TABLE IF EXISTS public.title_crew;