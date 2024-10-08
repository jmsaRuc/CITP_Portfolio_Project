-- Active: 1727253378954@@127.0.0.1@5532@portf_1
CREATE TABLE IF NOT EXISTS public.movie (
    movie_id character varying(10) NOT NULL,
    title character varying(256) NOT NULL,
    re_year character varying(4),
    run_time character varying(80),
    poster character varying(180),
    plot text,
    release_date date,
    imdb_rating numeric(5, 1),
    CONSTRAINT imdb_rating_check CHECK ((imdb_rating > (0)::numeric)),
    popularity integer,
    CONSTRAINT popularity_check CHECK ((popularity > (0)::integer))
);

CREATE TABLE IF NOT EXISTS public.user_movie_interaction (
    user_id character varying(10) NOT NULL,
    movie_id character varying(10),
    rating smallint,
    CONSTRAINT rating_check CHECK (rating BETWEEN 1 AND 10),
    watchlist integer,
    CONSTRAINT watchlist_check CHECK ((watchlist > (0)::integer))
);

CREATE TABLE IF NOT EXISTS public.user_series_interaction (
    user_id character varying(10) NOT NULL,
    series_id character varying(10),
    rating smallint,
    CONSTRAINT rating_check CHECK (rating BETWEEN 1 AND 10),
    watchlist integer,
    CONSTRAINT watchlist_check CHECK ((watchlist > (0)::integer))
);

CREATE Table IF NOT EXISTS public.user_episode_interaction (
    user_id character varying(10) NOT NULL,
    episode_id character varying(10),
    rating smallint,
    CONSTRAINT rating_check CHECK (rating BETWEEN 1 AND 10),
    watchlist integer,
    CONSTRAINT watchlist_check CHECK ((watchlist > (0)::integer))
);

CREATE TABLE if NOT EXISTS Public.movie_language (
    language character varying(200),
    movie_id character varying(10)
);

CREATE TABLE IF NOT EXISTS public.series_language (
    language character varying(200),
    series_id character varying(10)
);

CREATE TABLE IF NOT EXISTS public.episode_language (
    language character varying(200),
    episode_id character varying(10)
);

CREATE TABLE IF NOT EXISTS public.is_in_movie (
    person_id character varying(10) NOT NULL,
    movie_id character varying(10),
    cast_order integer,
    CONSTRAINT order_check CHECK ((cast_order > (0)::integer)),
    role character varying(50),
    job text,
    character text
);

CREATE TABLE IF NOT EXISTS public.is_in_series (
    person_id character varying(10) NOT NULL,
    series_id character varying(10),
    cast_order integer,
    CONSTRAINT order_check CHECK ((cast_order > (0)::integer)),
    role character varying(50),
    job text,
    character text
);

CREATE TABLE IF NOT EXISTS public.is_in_episode (
    person_id character varying(10) NOT NULL,
    episode_id character varying(10),
    cast_order integer,
    CONSTRAINT order_check CHECK ((cast_order > (0)::integer)),
    role character varying(50),
    job text,
    character text
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
    word text NOT NULL,
    field character varying(1) NOT NULL,
    lexeme text
);

CREATE TABLE IF NOT EXISTS public.series_keywords (
    series_id character varying(10),
    word text NOT NULL,
    field character varying(1) NOT NULL,
    lexeme text
);

CREATE TABLE IF NOT EXISTS public.episode_keywords (
    episode_id character varying(10),
    word text NOT NULL,
    field character varying(1) NOT NULL,
    lexeme text
);

CREATE TABLE IF NOT EXISTS public.person_keywords (
    person_id character varying(10),
    word text NOT NULL,
    field character varying(1) NOT NULL,
    lexeme text
);

CREATE TABLE IF NOT EXISTS public.person (
    person_id character varying(10) NOT NULL,
    name character varying(256) NOT NULL,
    birth_year character(4),
    death_year character(4),
    primary_profession character varying(256)
);

CREATE TABLE IF NOT EXISTS public.episode (
    episode_id character varying(10) NOT NULL,
    title character varying(256) NOT NULL,
    re_year character varying(4),
    run_time character varying(80),
    plot text,
    relese_date date,
    imdb_rating numeric(5, 1),
    CONSTRAINT imdb_rating_check CHECK ((imdb_rating > (0)::numeric)),
    popularity integer,
    CONSTRAINT popularity_check CHECK ((popularity > (0)::integer))
);

CREATE TABLE IF NOT EXISTS public.episode_series (
    series_id character varying(10),
    episode_id character varying(10),
    season_number integer,
    CONSTRAINT season_number_check CHECK (
        (season_number > (0)::integer)
    ),
    episode_number integer,
    CONSTRAINT episode_number_check CHECK (
        (
            episode_number >= (0)::integer
        )
    )
);

CREATE TABLE IF NOT EXISTS public.series (
    series_id character varying(10) NOT NULL,
    title character varying(256) NOT NULL,
    start_year character varying(4),
    end_year character varying(4),
    poster character varying(180),
    plot text,
    imdb_rating numeric(5, 1),
    CONSTRAINT imdb_rating_check CHECK ((imdb_rating > (0)::numeric)),
    popularity integer,
    CONSTRAINT popularity_check CHECK ((popularity > (0)::integer))
);

CREATE TABLE IF NOT EXISTS public.user (
    user_id character varying(10) NOT NULL,
    username character varying(256) NOT NULL,
    password bytea NOT NULL,
    email character varying(256) NOT NULL,
    created_at date
);

CREATE TABLE IF NOT EXISTS public.recent_view (
    user_id character varying(10) NOT NULL,
    title_type character varying(10) NOT NULL,
    CONSTRAINT title_type_check CHECK (
        title_type IN ('movie', 'series', 'episode', 'person')
    ),
    type_id character varying(10) NOT NULL,
    view_ordering integer,
    CONSTRAINT view_ordering CHECK (
        (view_ordering > (0)::integer)
    )
);

CREATE TABLE IF NOT EXISTS public.type (
    type_id character varying(10) NOT NULL,
    title_type character varying(10) NOT NULL,
    CONSTRAINT title_type_check CHECK (
        title_type IN ('movie', 'series', 'episode', 'person')
    )
);

-- movie import part 1
INSERT INTO
    movie (movie_id, title, re_year)
SELECT tconst, primarytitle, startyear
FROM title_basics
WHERE
    titletype != 'tvEpisode'
    AND titletype != 'tvMiniSeries'
    AND titletype != 'tvSeries'
    AND titletype != 'videoGame';

--movie import part 2¨
--

with
    not_an_epi as (
        SELECT movie_id as not_id
        FROM movie
    ),
    date_not_na as (
        SELECT
            tconst as _id,
            released,
            CASE
                WHEN released = 'N/A' THEN NULL
                ELSE TO_DATE(released, 'DD Mon YYYY')
            END as release_date
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
    And tconst = date_not_na._id
    and tconst = movie_id;

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
    or titletype = 'tvSeries';

-- series import part 2

with
    an_seris as (
        SELECT series_id as not_id
        FROM series
    )
UPDATE series
SET
    poster = omdb_data.poster,
    plot = omdb_data.plot
FROM omdb_data, an_seris
WHERE
    tconst = an_seris.not_id
    and tconst = series_id;

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
with
    an_epi as (
        SELECT episode_id as not_id
        FROM episode
    ),
    date_not_na as (
        SELECT
            tconst as _id,
            released,
            CASE
                WHEN released = 'N/A' THEN NULL
                ELSE TO_DATE(released, 'DD Mon YYYY')
            END as release_date
        FROM omdb_data
    )
UPDATE episode
SET
    run_time = runtime,
    plot = omdb_data.plot,
    relese_date = date_not_na.release_date
FROM omdb_data, an_epi, date_not_na
WHERE
    tconst = an_epi.not_id
    And tconst = date_not_na._id
    and tconst = episode_id;

-- episode import part 3
UPDATE episode
SET
    imdb_rating = averagerating
FROM title_ratings
WHERE
    episode_id = tconst;

-- import series episodes relation part 1
INSERT into
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
    split_part(primaryprofession, ',', 1) as primary_profession
FROM name_basics;

-- movie_genre
INSERT INTO
    movie_genre (genre_name, movie_id)
SELECT string_to_table(genres, ',') as genre, tconst
FROM title_basics
WHERE
    genres IS NOT NULL
    and titletype != 'tvEpisode'
    AND titletype != 'tvMiniSeries'
    AND titletype != 'tvSeries'
    AND titletype != 'videoGame';

-- series_genre
INSERT INTO
    series_genre (genre_name, series_id)
SELECT string_to_table(genres, ',') as genre, tconst
FROM title_basics
WHERE
    genres IS NOT NULL
    and titletype = 'tvMiniSeries'
    or titletype = 'tvSeries';

-- episode_genre
INSERT INTO
    episode_genre (genre_name, episode_id)
SELECT string_to_table(genres, ',') as genre, tconst
FROM title_basics
WHERE
    genres IS NOT NULL
    and titletype = 'tvEpisode';

-- is_in_movie
INSERT INTO
    is_in_movie (
        person_id,
        movie_id,
        cast_order,
        role,
        job,
        character
    )
with
    titletype_movie as (
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
        role,
        job,
        character
    )
with
    titletype_series as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvMiniSeries'
            or titletype = 'tvSeries'
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
        role,
        job,
        character
    )
with
    titletype_episode as (
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
with
    titletype_episode as (
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
with
    titletype_series as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvMiniSeries'
            or titletype = 'tvSeries'
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
with
    titletype_episode as (
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
    movie_language (language, movie_id)
with
    titletype_movie as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype != 'tvEpisode'
            AND titletype != 'tvMiniSeries'
            AND titletype != 'tvSeries' 
            AND titletype != 'videoGame'
    )
SELECT string_to_table(language, ','), tconst
FROM omdb_data NATURAL JOIN titletype_movie
WHERE tconst != 'tt3795628';

INSERT INTO
    movie_language (language, movie_id)
VALUES ('English', 'tt3795628');    
-- series_language
INSERT INTO
    series_language (language, series_id)
with
    titletype_series as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvMiniSeries'
            or titletype = 'tvSeries'
    )
SELECT string_to_table(language, ','), omdb_data.tconst
FROM omdb_data, titletype_series
WHERE  omdb_data.tconst = titletype_series.tconst;

-- episode_language
INSERT INTO
    episode_language (language, episode_id)
with
    titletype_episode as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvEpisode'
    )
SELECT string_to_table(language, ','), omdb_data.tconst
FROM omdb_data, titletype_episode
WHERE omdb_data.tconst= titletype_episode.tconst;

-- import type

INSERT INTO public.type (type_id, title_type)
with
    type_change as (
        SELECT
            tconst,
            titletype,
            CASE
                WHEN titletype = 'tvEpisode' THEN 'episode'
                WHEN titletype = 'tvMiniSeries' THEN 'series'
                WHEN titletype = 'tvSeries' THEN 'series'
                WHEN titletype = 'videoGame' THEN NULL
                ELSE 'movie'
            END as type_name_v
        FROM title_basics
    )
SELECT tconst, type_change.type_name_v
FROM type_change
WHERE
    type_change.type_name_v IS NOT NULL;

-- import person type

INSERT INTO public.type (type_id, title_type)
SELECT person_id, 'person' 
FROM person;




ALTER TABLE IF EXISTS public.movie
ADD CONSTRAINT movie_pkey PRIMARY KEY (movie_id);

ALTER TABLE IF EXISTS public.type
ADD CONSTRAINT type_pkey PRIMARY KEY (type_id);

ALTER TABLE IF EXISTS public.user_movie_interaction
ADD CONSTRAINT user_movie_interaction_pkey PRIMARY KEY (user_id, movie_id);

ALTER TABLE IF EXISTS public.user_series_interaction
ADD CONSTRAINT user_series_interaction_pkey PRIMARY KEY (user_id, series_id);

ALTER TABLE IF EXISTS public.user_episode_interaction
ADD CONSTRAINT user_episode_interaction_pkey PRIMARY KEY (user_id, episode_id);

ALTER TABLE IF EXISTS public.movie_language
ADD CONSTRAINT movie_language_pkey PRIMARY KEY (language, movie_id);

ALTER TABLE IF EXISTS public.series_language
ADD CONSTRAINT series_language_pkey PRIMARY KEY (language, series_id);

ALTER TABLE IF EXISTS public.episode_language
ADD CONSTRAINT episode_language_pkey PRIMARY KEY (language, episode_id);

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

ALTER TABLE IF EXISTS public.user_movie_interaction
ADD CONSTRAINT user_movie_interaction_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie (movie_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_series_interaction
ADD CONSTRAINT user_series_interaction_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series (series_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.user_episode_interaction
ADD CONSTRAINT user_episode_interaction_episode_id_fkey FOREIGN KEY (episode_id) REFERENCES public.episode (episode_id) ON UPDATE CASCADE ON DELETE CASCADE;

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

DROP TABLE IF EXISTS public.title_basics;

DROP TABLE IF EXISTS public.title_episode;

DROP TABLE IF EXISTS public.title_principals;

DROP TABLE IF EXISTS public.title_ratings;

DROP TABLE IF EXISTS public.omdb_data;

DROP TABLE IF EXISTS public.name_basics;

DROP TABLE IF EXISTS public.wi;

DROP TABLE IF EXISTS public.title_akas;

DROP TABLE IF EXISTS public.title_crew;


