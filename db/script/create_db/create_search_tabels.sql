SET search_path TO public, pgtap, fuzzy;

----------------------------------------------------------------------
--movie
---------------------------------------------------------------------

CREATE TABLE public.movie_search AS TABLE public.movie;

ALTER TABLE IF EXISTS public.movie_search
ADD genres TEXT NOT NULL DEFAULT '',
ADD "language" TEXT NOT NULL DEFAULT '',
ADD directors TEXT NOT NULL DEFAULT '',
ADD writers TEXT NOT NULL DEFAULT '',
ADD top_actors_name TEXT NOT NULL DEFAULT '',
ADD top_actors_character TEXT NOT NULL DEFAULT '';

----add genres to movie search
WITH
    genre_arg AS (
        SELECT movie_id AS f, string_agg(genre_name::TEXT, ',') AS genres
        FROM public.movie_genre
        GROUP BY
            movie_id
    )
UPDATE public.movie_search AS s
SET
    genres = genre_arg.genres
FROM genre_arg
WHERE
    genre_arg.f = s.movie_id;

----add director to movie search
WITH
    is_is AS (
        SELECT
            movie_id,
            person_id,
            "role",
            job,
            "character",
            cast_order
        FROM is_in_movie
        WHERE
            "role" = 'director'
            OR job = 'directed by'
    ),
    get_name AS (
        SELECT movie_id, "name" AS name_d
        FROM is_is
            NATURAL JOIN public.person
    ),
    agr AS (
        SELECT movie_id AS f, string_agg(name_d::TEXT, ',') AS dire
        FROM get_name
        GROUP BY
            movie_id
    )
UPDATE public.movie_search AS s
SET
    directors = agr.dire
FROM agr
WHERE
    agr.f = s.movie_id;

------add writer to movie search
WITH
    is_is AS (
        SELECT
            movie_id,
            person_id,
            "role",
            job,
            "character",
            cast_order
        FROM is_in_movie
        WHERE
            "role" = 'writer'
            OR job = 'writen by'
    ),
    get_name AS (
        SELECT movie_id, "name" AS name_d
        FROM is_is
            NATURAL JOIN public.person
    ),
    agr AS (
        SELECT movie_id AS f, string_agg(name_d::TEXT, ',') AS dire
        FROM get_name
        GROUP BY
            movie_id
    )
UPDATE public.movie_search AS s
SET
    writers = agr.dire
FROM agr
WHERE
    agr.f = s.movie_id;

-------add top cast to movie search
WITH
    in_movie AS (
        SELECT
            movie_id,
            person_id,
            "character",
            cast_order
        FROM public.is_in_movie
        WHERE (
                "role" = 'actor'
                OR "role" = 'actress'
            )
    ),
    persons_in AS (
        SELECT person_id, "name"
        FROM public.person
        WHERE
            person_id IN (
                SELECT person_id
                FROM in_movie
            )
    ),
    get_name AS (
        SELECT
            movie_id,
            person_id,
            "name" AS name_d,
            "character" AS char_d,
            cast_order
        FROM in_movie
            NATURAL JOIN persons_in
    ),
    arg AS (
        SELECT
            movie_id AS f,
            string_agg(name_d::TEXT, ',') AS actors_name,
            string_agg(char_d::TEXT, ',') AS actors_characters
        FROM get_name
        GROUP BY
            movie_id
    )
UPDATE public.movie_search AS s
SET
    top_actors_name = arg.actors_name,
    top_actors_character = arg.actors_characters
FROM arg
WHERE
    arg.f = s.movie_id;
---------------------------------add language to movie search
WITH
    arg AS (
        SELECT movie_id AS f, string_agg("language"::TEXT, ',') AS lang
        FROM public.movie_language
        GROUP BY
            movie_id
    )
UPDATE public.movie_search AS s
SET
    "language" = arg.lang
FROM arg
WHERE
    arg.f = s.movie_id;

------------send search text to vector

ALTER TABLE IF EXISTS public.movie_search
ADD "search" tsvector GENERATED ALWAYS AS (
    setweight(
        to_tsvector('english', title),
        'A'
    ) || ' ' || setweight(
        to_tsvector('english', coalesce(plot, '')),
        'C'
    ) || ' ' || setweight(
        to_tsvector(
            'simple',
            coalesce(genres, '')
        ),
        'C'
    ) || ' ' || setweight(
        to_tsvector(
            'simple',
            coalesce(directors, '')
        ),
        'B'
    ) || ' ' || setweight(
        to_tsvector(
            'simple',
            coalesce(writers, '')
        ),
        'D'
    ) || '' || setweight(
        to_tsvector(
            'simple',
            coalesce(top_actors_name, '')
        ),
        'C'
    ) || '' || setweight(
        to_tsvector(
            'simple',
            coalesce(top_actors_character, '')
        ),
        'B'
    )
) STORED;

ALTER TABLE IF EXISTS public.movie_search
DROP COLUMN re_year,
DROP COLUMN run_time;
--create indexes


ALTER TABLE IF EXISTS public.movie_search
ADD CONSTRAINT movie_search_pkey PRIMARY KEY (movie_id);


ALTER TABLE IF EXISTS public.movie_search
ADD CONSTRAINT movie_search_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie (movie_id) ON UPDATE CASCADE ON DELETE CASCADE;


CREATE INDEX idx_search ON public.movie_search USING GIN ("search");

CREATE INDEX trgm_idx_gin ON public.movie_search USING GIN (title gin_trgm_ops);

CREATE INDEX IF NOT EXISTS IX_movie_search_pop_avg_and_imdb_rating ON public.movie_search (
    popularity DESC,
    imdb_rating DESC,
    average_rating DESC
);

-----------------------------------------------------------------------------------------------------------------------
--series
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE public.series_search AS TABLE public.series;

ALTER TABLE IF EXISTS public.series_search
ADD genres TEXT NOT NULL DEFAULT '',
ADD "language" TEXT NOT NULL DEFAULT '',
ADD creator TEXT NOT NULL DEFAULT '',
ADD writers TEXT NOT NULL DEFAULT '',
ADD top_actors_name TEXT NOT NULL DEFAULT '',
ADD top_actors_character TEXT NOT NULL DEFAULT '',
ADD episodes_titles TEXT NOT NULL DEFAULT '';

----add genres to series search
WITH
    genre_arg AS (
        SELECT series_id AS f, string_agg(genre_name::TEXT, ',') AS genres
        FROM public.series_genre
        GROUP BY
            series_id
    )
UPDATE public.series_search AS s
SET
    genres = genre_arg.genres
FROM genre_arg
WHERE
    genre_arg.f = s.series_id;

----add creator to series search
WITH
    is_is AS (
        SELECT
            series_id,
            person_id,
            "role",
            job,
            "character",
            cast_order
        FROM is_in_series
        WHERE
            "role" = 'writer'
            and job = 'created by'
    ),
    get_name AS (
        SELECT series_id, "name" AS name_d
        FROM is_is
            NATURAL JOIN public.person
    ),
    agr AS (
        SELECT series_id AS f, string_agg(name_d::TEXT, ',') AS dire
        FROM get_name
        GROUP BY
            series_id
    )
UPDATE public.series_search AS s
SET
    creator = agr.dire
FROM agr
WHERE
    agr.f = s.series_id;




------add writer to series search

WITH
    is_is AS (
        SELECT
            series_id,
            person_id,
            "role",
            job,
            "character",
            cast_order
        FROM is_in_series
        WHERE
            "role" = 'writer'
            OR job = 'writen by'
    ),
    get_name AS (
        SELECT series_id, "name" AS name_d
        FROM is_is
            NATURAL JOIN public.person
    ),
    agr AS (
        SELECT series_id AS f, string_agg(name_d::TEXT, ',') AS dire
        FROM get_name
        GROUP BY
            series_id
    )
UPDATE public.series_search AS s
SET
    writers = agr.dire
FROM agr
WHERE
    agr.f = s.series_id;

-------add top cast to series search
WITH
    in_series AS (
        SELECT
            series_id,
            person_id,
            "character",
            cast_order
        FROM public.is_in_series
        WHERE (
                "role" = 'actor'
                OR "role" = 'actress'
            )
    ),
    persons_in AS (
        SELECT person_id, "name"
        FROM public.person
        WHERE
            person_id IN (
                SELECT person_id
                FROM in_series
            )
    ),
    get_name AS (
        SELECT
            series_id,
            person_id,
            "name" AS name_d,
            "character" AS char_d,
            cast_order
        FROM in_series
            NATURAL JOIN persons_in
        ORDER BY cast_order ASC
    ),
    arg AS (
        SELECT
            series_id AS f,
            string_agg(name_d::TEXT, ',') AS actors_name,
            string_agg(char_d::TEXT, ',') AS actors_characters
        FROM get_name
        GROUP BY
            series_id
    )
UPDATE public.series_search AS s
SET
    top_actors_name = arg.actors_name,
    top_actors_character = arg.actors_characters
FROM arg
WHERE
    arg.f = s.series_id;

----add language to series search
WITH
    arg AS (
        SELECT series_id AS f, string_agg("language"::TEXT, ',') AS lang
        FROM public.series_language
        GROUP BY
            series_id
    )
UPDATE public.series_search AS s
SET
    "language" = arg.lang
FROM arg
WHERE
    arg.f = s.series_id;

----add top episodes to series search

WITH
    arg AS (
        SELECT series_id, popularity, string_agg(title::TEXT, ',') AS lang
        FROM public.episode
            NATURAL JOIN episode_series
        GROUP BY
            series_id,
            popularity
        ORDER BY popularity DESC
    )
UPDATE public.series_search AS s
SET
    episodes_titles = arg.lang
FROM arg
WHERE
    arg.series_id = s.series_id;
------------send search text to vector
ALTER TABLE IF EXISTS public.series_search
ADD "search" tsvector GENERATED ALWAYS AS (
    setweight(
        to_tsvector('english', title),
        'A'
    ) || ' ' || setweight(
        to_tsvector('english', coalesce(plot, '')),
        'C'
    ) || ' ' || setweight(
        to_tsvector(
            'simple',
            coalesce(genres, '')
        ),
        'C'
    ) || ' ' || setweight(
        to_tsvector(
            'simple',
            coalesce(creator, '')
        ),
        'C'
    ) || ' ' || setweight(
        to_tsvector(
            'simple',
            coalesce(writers, '')
        ),
        'D'
    ) || '' || setweight(
        to_tsvector(
            'simple',
            coalesce(top_actors_name, '')
        ),
        'C'
    ) || '' || setweight(
        to_tsvector(
            'simple',
            coalesce(top_actors_character, '')
        ),
        'D'
    ) || '' || setweight(
        to_tsvector(
            'english',
            coalesce(episodes_titles, '')
        ),
        'B'
    )
) STORED;

ALTER TABLE IF EXISTS public.series_search
ADD CONSTRAINT series_search_pkey PRIMARY KEY (series_id);


ALTER TABLE IF EXISTS public.series_search
ADD CONSTRAINT series_search_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series (series_id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE INDEX idx_series_search ON public.series_search USING GIN ("search");

CREATE INDEX trgm_idx_gin_series_search ON public.series_search USING GIN (title gin_trgm_ops);

CREATE INDEX IF NOT EXISTS IX_series_search_pop_avg_and_imdb_rating ON public.series_search (
    popularity DESC,
    imdb_rating DESC,
    average_rating DESC
);

-----------------------------------------------------------------------------------------------------------------------
--episode
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE public.episode_search AS TABLE public.episode;

ALTER TABLE IF EXISTS public.episode_search
ADD genres TEXT NOT NULL DEFAULT '',
ADD "language" TEXT NOT NULL DEFAULT '',
ADD directors TEXT NOT NULL DEFAULT '',
ADD writers TEXT NOT NULL DEFAULT '',
ADD top_actors_name TEXT NOT NULL DEFAULT '',
ADD top_actors_character TEXT NOT NULL DEFAULT '',
ADD series_title TEXT NOT NULL DEFAULT '';

----add genres to episode search
WITH
    genre_arg AS (
        SELECT episode_id AS f, string_agg(genre_name::TEXT, ',') AS genres
        FROM public.episode_genre
        GROUP BY
            episode_id
    )
UPDATE public.episode_search AS s
SET
    genres = genre_arg.genres
FROM genre_arg
WHERE
    genre_arg.f = s.episode_id;

----add director to episode search
WITH
    is_is AS (
        SELECT
            episode_id,
            person_id,
            "role",
            job,
            "character",
            cast_order
        FROM is_in_episode
        WHERE
            "role" = 'director'
            OR job = 'directed by'
    ),
    get_name AS (
        SELECT episode_id, "name" AS name_d
        FROM is_is
            NATURAL JOIN public.person
    ),
    agr AS (
        SELECT episode_id AS f, string_agg(name_d::TEXT, ',') AS dire
        FROM get_name
        GROUP BY
            episode_id
    )
UPDATE public.episode_search AS s
SET
    directors = agr.dire
FROM agr
WHERE
    agr.f = s.episode_id;

------add writer to episode search
WITH
    is_is AS (
        SELECT
            episode_id,
            person_id,
            "role",
            job,
            "character",
            cast_order
        FROM is_in_episode
        WHERE
            "role" = 'writer'
            OR job = 'writen by'
    ),
    get_name AS (
        SELECT episode_id, "name" AS name_d
        FROM is_is
            NATURAL JOIN public.person
    ),
    agr AS (
        SELECT episode_id AS f, string_agg(name_d::TEXT, ',') AS dire
        FROM get_name
        GROUP BY
            episode_id
    )
UPDATE public.episode_search AS s
SET
    writers = agr.dire
FROM agr
WHERE
    agr.f = s.episode_id;

-------add top cast to episode search
WITH
    in_episode AS (
        SELECT
            episode_id,
            person_id,
            "character",
            cast_order
        FROM public.is_in_episode
        WHERE (
                "role" = 'actor'
                OR "role" = 'actress'
            )
    ),
    persons_in AS (
        SELECT person_id, "name"
        FROM public.person
        WHERE
            person_id IN (
                SELECT person_id
                FROM in_episode
            )
    ),
    get_name AS (
        SELECT
            episode_id,
            person_id,
            "name" AS name_d,
            "character" AS char_d,
            cast_order
        FROM in_episode
            NATURAL JOIN persons_in
        ORDER BY cast_order ASC
    ),
    arg AS (
        SELECT
            episode_id AS f,
            string_agg(name_d::TEXT, ',') AS actors_name,
            string_agg(char_d::TEXT, ',') AS actors_characters
        FROM get_name
        GROUP BY
            episode_id
    )
UPDATE public.episode_search AS s
SET
    top_actors_name = arg.actors_name,
    top_actors_character = arg.actors_characters
FROM arg
WHERE
    arg.f = s.episode_id;

----add language to episode search
WITH
    arg AS (
        SELECT episode_id AS f, string_agg("language"::TEXT, ',') AS lang
        FROM public.episode_language
        GROUP BY
            episode_id
    )
UPDATE public.episode_search AS s
SET
    "language" = arg.lang
FROM arg
WHERE
    arg.f = s.episode_id;

----add series title to episode search
WITH
    arg AS (
        SELECT episode_id AS f, popularity, string_agg(title::TEXT, ',') AS lang
        FROM public.series
            NATURAL JOIN episode_series
        GROUP BY
            episode_id,
            popularity
        ORDER BY popularity DESC
    )
UPDATE public.episode_search AS s
SET
    series_title = arg.lang
FROM arg
WHERE
    arg.f = s.episode_id;

------------send search text to vector
ALTER TABLE IF EXISTS public.episode_search
ADD "search" tsvector GENERATED ALWAYS AS (
    setweight(
        to_tsvector('english', title),
        'B'
    ) || ' ' || setweight(
        to_tsvector('english', coalesce(plot, '')),
        'C'
    ) || ' ' || setweight(
        to_tsvector(
            'simple',
            coalesce(genres, '')
        ),
        'C'
    ) || ' ' || setweight(
        to_tsvector(
            'simple',
            coalesce(directors, '')
        ),
        'B'
    ) || ' ' || setweight(
        to_tsvector(
            'simple',
            coalesce(writers, '')
        ),
        'D'
    ) || '' || setweight(
        to_tsvector(
            'simple',
            coalesce(top_actors_name, '')
        ),
        'C'
    ) || '' || setweight(
        to_tsvector(
            'simple',
            coalesce(top_actors_character, '')
        ),
        'D'
    ) || '' || setweight(
        to_tsvector(
            'english',
            coalesce(series_title, '')
        ),
        'A'
    )
) STORED;

ALTER TABLE IF EXISTS public.episode_search
DROP COLUMN re_year,
DROP COLUMN run_time;


----create indexes

ALTER TABLE IF EXISTS public.episode_search
ADD CONSTRAINT episode_search_pkey PRIMARY KEY (episode_id);

ALTER TABLE IF EXISTS public.episode_search
ADD CONSTRAINT episode_search_episode_id_fkey FOREIGN KEY (episode_id) REFERENCES public.episode (episode_id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE INDEX idx_episode_search ON public.episode_search USING GIN ("search");

CREATE INDEX trgm_idx_gin_episode_search ON public.episode_search USING GIN (title gin_trgm_ops);

CREATE INDEX IF NOT EXISTS IX_episode_search_pop_avg_and_imdb_rating ON public.episode_search (
    popularity DESC,
    imdb_rating DESC,
    average_rating DESC
);


-----------------------------------------------------------------------------------------------------------------------
--person
-----------------------------------------------------------------------------------------------------------------------

CREATE TABLE public.person_search AS TABLE public.person;

ALTER TABLE IF EXISTS public.person_search
ADD known_for TEXT NOT NULL DEFAULT '',
ADD "characters" TEXT NOT NULL DEFAULT '';

----add known for to person search
with filt_in as (
                SELECT
                    person_id,
                    episode_id AS title_id_v,
                    title AS title_v,
                    "character" as character_v
                FROM is_in_episode NATURAL JOIN public.episode
                WHERE cast_order <= 10
                UNION ALL
                SELECT
                    person_id,
                    series_id AS title_id_v,
                    title AS title_v,
                    "character" as character_v
                FROM is_in_series NATURAL JOIN public.series
                WHERE cast_order <= 10
                UNION ALL
                SELECT
                    person_id,
                    movie_id AS title_id_v,
                    title AS title_v,
                    "character" as character_v
                FROM is_in_movie NATURAL JOIN public.movie
                WHERE cast_order <= 10
            ), arg as (
                SELECT person_id AS f, string_agg(title_v::TEXT, ',') AS known_for, string_agg(character_v::TEXT, ',') AS "characters"
                FROM filt_in
                GROUP BY person_id
            )
    UPDATE public.person_search AS s
    SET
        known_for = arg.known_for,
        "characters" = arg."characters"
    FROM arg
    WHERE
        arg.f = s.person_id;

------------send search text to vector
ALTER TABLE IF EXISTS public.person_search
ADD "search" tsvector GENERATED ALWAYS AS (
    setweight(
        to_tsvector('english', "name"),
        'A'
    ) || ' ' || setweight(
        to_tsvector('english', coalesce(primary_profession, '')),
        'C'
    ) || ' ' || setweight(
        to_tsvector(
            'english',
            coalesce(known_for, '')
        ),
        'A'
    ) || ' ' || setweight(
        to_tsvector(
            'simple',
            coalesce("characters", '')
        ),
        'B'
    )
) STORED;

ALTER TABLE IF EXISTS public.person_search
DROP COLUMN birth_year,
DROP COLUMN death_year;


-----create indexes
ALTER TABLE IF EXISTS public.person_search
ADD CONSTRAINT person_search_pkey PRIMARY KEY (person_id);

ALTER TABLE IF EXISTS public.person_search
ADD CONSTRAINT person_search_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person (person_id) ON UPDATE CASCADE ON DELETE CASCADE;


CREATE INDEX idx_person_search ON public.person_search USING GIN ("search");

CREATE INDEX trgm_idx_gin_person_search ON public.person_search USING GIN ("name" gin_trgm_ops);

CREATE INDEX IF NOT EXISTS IX_person_search_pop_avg_and_imdb_rating ON public.person_search (
    popularity DESC
);
