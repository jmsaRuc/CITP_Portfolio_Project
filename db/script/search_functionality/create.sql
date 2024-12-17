--------------------------------------------------------------
--misc
-------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS fuzzy;

CREATE EXTENSION pg_trgm SCHEMA fuzzy;

SET search_path TO public, pgtap, fuzzy;

------------------------series

------------------------episode

----------------------all

-----------------------------------------------------------------------
--general functions
-----------------------------------------------------------------------
----fuzzy rank
CREATE OR REPLACE FUNCTION public.get_fuzzy_rank(title text, search_query text)
   RETURNS NUMERIC AS $$
      select fuzzy.similarity(title, search_query) * (title <-> websearch_to_tsquery('english', search_query)::text);
$$ LANGUAGE SQL;

-----rank boost w system  0.5 A, 0.05 B, 0.005 C, 0.0005 D

-----rank_boost on rating with popularity thresh hold rank B
CREATE OR REPLACE FUNCTION public.rank_boost_rating(rating numeric, popularity BIGINT, voteThreshold BIGINT)
	returns numeric as $$
		select case when popularity < voteThreshold then 0 else (rating*0.05) end;
$$ language sql;

------rank_boost on release date on with popularity thresh hold rank b
CREATE OR REPLACE FUNCTION public.rank_boost_relese_date(relase_date date, now_date date, popularity BIGINT, voteThreshold BIGINT)
    returns numeric as $$
        select case when popularity < voteThreshold or relase_date is NULL then 0 else (1/(((now_date - relase_date)::numeric)/364))*0.05 end;
$$ language sql;

------------rank_boost on language rank english higher rank D
CREATE OR REPLACE FUNCTION public.rank_boost_language("language" text)
	returns NUMERIC as $$
    BEGIN
        if "language" is NULL or "language" = ''
        then
            return 0;
        ELSEIF position('English' in "language") > 0
            THEN
                RETURN 0.005;
            ELSE
                RETURN 0;
        END IF;
    END;
$$ language plpgsql;

------------rank_boost on rank on recent_viewed rank b
CREATE OR REPLACE FUNCTION public.rank_boost_recent_viewed(type_id_v VARCHAR, user_id_v VARCHAR)
    RETURNS NUMERIC AS $$
    BEGIN
        if EXISTS(
                SELECT
                    TRUE
                FROM recent_view
                WHERE
                "user_id" = user_id_v and "type_id" = type__id_v
        )
        THEN
            RETURN 0.05;
        ELSE
            RETURN 0;
        END IF;
    END;
$$ LANGUAGE plpgsql;

--------------------------------------------------------------------------------------------------------------
-----main
--------------------------------------------------------------------------------------------------------------

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

CREATE INDEX idx_search ON public.movie_search USING GIN (SEARCH);

CREATE INDEX trgm_idx_gin ON public.movie_search USING GIN (title gin_trgm_ops);

CREATE INDEX IF NOT EXISTS IX_movie_search_pop_avg_and_imdb_rating ON public.movie_search (
    popularity DESC,
    imdb_rating DESC,
    average_rating DESC
);

-----------------------------------------------------------------------------------------------
-- movie search function

CREATE OR REPLACE FUNCTION search_movie_quick(search_query TEXT, user_id_v VARCHAR)
    RETURNS TABLE(
        movie_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
BEGIN
    IF length(search_query) <= 2
    THEN
        RETURN;
    ELSEIF coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE            
        RETURN QUERY
            SELECT 
                movie_id, title, poster, average_rating, imdb_rating, popularity, ts_headline(
                    'english', q.title, websearch_to_tsquery('english', search_query), 
                    'MaxFragments=3,MaxWords=25,MinWords=2') highlight, q."rank"
            FROM (
                    SELECT ts_rank(
                            f."search", websearch_to_tsquery('english', search_query)
                        ) 
                        + public.rank_boost_rating (imdb_rating, popularity, 5) 
                        + public.rank_boost_language("language") 
                        + public.rank_boost_relese_date(release_date, CURRENT_DATE, popularity, 5)
                        + public.rank_boost_recent_viewed(movie_id, user_id_v)
                        + public.get_fuzzy_rank (title, search_query) 
                        RANK, *
                    FROM public.movie_search f, websearch_to_tsquery('english', search_query) AS tsq
                    WHERE
                        f."search" @@ to_tsquery('english', tsq::TEXT || ':*')
                ) q
            WHERE
                q.rank > 0.001
            ORDER BY RANK DESC NULLS LAST;
    END IF;        
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION search_movie_slow(search_query TEXT)
    RETURNS TABLE(
        movie_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
BEGIN
    IF length(search_query) <= 4
    THEN
        RETURN;
    ELSEIF
        coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE    
        RETURN QUERY
            WITH
                ranked_search AS (
                    SELECT ts_rank(
                            "search", websearch_to_tsquery('english', search_query)
                        ) 
                        + public.rank_boost_rating (imdb_rating, popularity, 5)
                        RANK, movie_id, title, poster, average_rating, imdb_rating, popularity
                    FROM public.movie_search
                    ORDER BY RANK DESC NULLS LAST
                    LIMIT 1000
                )
            SELECT movie_id, title, poster, average_rating, imdb_rating, popularity, 
                ts_headline(
                    'english', title, websearch_to_tsquery('english', search_query), 'MaxFragments=3,MaxWords=25,MinWords=2'
                ) Highlight, "rank"
            FROM ranked_search
            ORDER BY public.get_fuzzy_rank (
                    title,
                    to_tsquery(
                        'simple',
                        websearch_to_tsquery('english', search_query)::TEXT || ':*')::TEXT
                    ) DESC;

    END IF;
END;
$$ LANGUAGE plpgsql;

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

CREATE INDEX idx_series_search ON public.series_search USING GIN ("search");

CREATE INDEX trgm_idx_gin_series_search ON public.series_search USING GIN (title gin_trgm_ops);

CREATE INDEX IF NOT EXISTS IX_series_search_pop_avg_and_imdb_rating ON public.series_search (
    popularity DESC,
    imdb_rating DESC,
    average_rating DESC
);
-----------------------------------------------seriesh spicific boost rank functions
CREATE OR REPLACE FUNCTION public.rank_boost_series_relese_date(start_year_v varchar(4), popularity BIGINT, voteThreshold BIGINT)
    returns numeric as $$
            DECLARE
                start_year date;
            BEGIN
                if start_year_v is NULL or start_year_v = ''
                then
                    return 0;
                ELSE
                    start_year := to_date(start_year_v, 'YYYY');
                    if popularity < voteThreshold or start_year is NULL
                    then
                        return 0;
                    ELSE
                        return (1/(((CURRENT_DATE - start_year)::numeric)/364))*0.005;
                    END IF;
                END IF;
            END;
$$ language plpgsql;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- series search function
CREATE OR REPLACE FUNCTION search_series_quick(search_query TEXT, user_id_v VARCHAR)
    RETURNS TABLE(
        series_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v double precision) AS $$
BEGIN
    IF length(search_query) <= 2
    THEN
        RETURN;
    ELSEIF coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE            
        RETURN QUERY
            SELECT 
                series_id, title, poster, average_rating, imdb_rating, popularity, ts_headline(
                    'english', q.title, websearch_to_tsquery('english', search_query), 
                    'MaxFragments=3,MaxWords=25,MinWords=2') highlight, q."rank"
            FROM (
                    SELECT ts_rank(
                            f."search", websearch_to_tsquery('english', search_query)
                        ) 
                        + public.rank_boost_rating (imdb_rating, popularity, 5) 
                        + public.rank_boost_language("language") 
                        + public.rank_boost_series_relese_date(start_year, popularity, 5)
                        + public.rank_boost_recent_viewed(series_id, user_id_v)
                        + public.get_fuzzy_rank (title, search_query) 
                        "rank", *
                    FROM public.series_search f, websearch_to_tsquery('english', search_query) AS tsq
                    WHERE
                        f."search" @@ to_tsquery('english', tsq::TEXT || ':*')
                ) q
            WHERE
                q.rank > 0.001
            ORDER BY "rank" DESC NULLS LAST;
    END IF;        
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION public.search_series_slow(search_query TEXT)
    RETURNS TABLE(
        series_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
        BEGIN
    IF length(search_query) <= 4
    THEN
        RETURN;
    ELSEIF
        coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE    
        RETURN QUERY
        WITH
            ranked_search AS (
                SELECT ts_rank(
                        "search", websearch_to_tsquery('english', search_query)
                    ) 
                    + public.rank_boost_rating (imdb_rating, popularity, 5)
                    "rank", series_id, title, poster, average_rating, imdb_rating, popularity
                FROM public.series_search
                ORDER BY "rank" DESC NULLS LAST
                LIMIT 1000
            )
        SELECT series_id, title, poster, average_rating, imdb_rating, popularity, 
            ts_headline(
                'english', title, websearch_to_tsquery('english', search_query), 'MaxFragments=3,MaxWords=25,MinWords=2'
            ) highlight, "rank"
        FROM ranked_search
        ORDER BY public.get_fuzzy_rank (
                title,
                to_tsquery(
                    'simple',
                    websearch_to_tsquery('english', search_query)::TEXT || ':*')::TEXT
                ) DESC;
    END IF;
END;
$$ LANGUAGE plpgsql;



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
CREATE INDEX idx_episode_search ON public.episode_search USING GIN ("search");

CREATE INDEX trgm_idx_gin_episode_search ON public.episode_search USING GIN (title gin_trgm_ops);

CREATE INDEX IF NOT EXISTS IX_episode_search_pop_avg_and_imdb_rating ON public.episode_search (
    popularity DESC,
    imdb_rating DESC,
    average_rating DESC
);

-----------------------------------------------------------------------------------------------------------------------
--episode search function

CREATE OR REPLACE FUNCTION search_episode_quick(search_query TEXT, user_id_v VARCHAR)
    RETURNS TABLE(
        episode_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
BEGIN
    IF length(search_query) <= 2
    THEN
        RETURN;
    ELSEIF coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE            
        RETURN QUERY
            SELECT 
                episode_id, title, poster, average_rating, imdb_rating, popularity, ts_headline(
                    'english', q.title, websearch_to_tsquery('english', search_query), 
                    'MaxFragments=3,MaxWords=25,MinWords=2') highlight, q."rank"
            FROM (
                    SELECT ts_rank(
                            f."search", websearch_to_tsquery('english', search_query)
                        ) 
                        + public.rank_boost_rating (imdb_rating, popularity, 5) 
                        + public.rank_boost_language("language")
                        + public.rank_boost_relese_date(relese_date, CURRENT_DATE, popularity, 5)
                        + public.rank_boost_recent_viewed(episode_id, user_id_v)
                        + public.get_fuzzy_rank (title, search_query) 
                        "rank", *
                    FROM public.episode_search f, websearch_to_tsquery('english', search_query) AS tsq
                    WHERE
                        f."search" @@ to_tsquery('english', tsq::TEXT || ':*')
                ) q
            WHERE
                q.rank > 0.001
            ORDER BY "rank" DESC NULLS LAST;
    END IF;        
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.search_episode_slow(search_query TEXT)
    RETURNS TABLE(
        episode_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
        BEGIN
    IF length(search_query) <= 4
    THEN
        RETURN;
    ELSEIF
        coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE    
        RETURN QUERY
        WITH
            ranked_search AS (
                SELECT ts_rank(
                        "search", websearch_to_tsquery('english', search_query)
                    ) 
                    + public.rank_boost_rating (imdb_rating, popularity, 5)
                    "rank", episode_id, title, poster, average_rating, imdb_rating, popularity
                FROM public.episode_search
                ORDER BY "rank" DESC NULLS LAST
                LIMIT 1000
            )
        SELECT episode_id, title, poster, average_rating, imdb_rating, popularity, 
            ts_headline(
                'english', title, websearch_to_tsquery('english', search_query), 'MaxFragments=3,MaxWords=25,MinWords=2'
            ) highlight, "rank"
        FROM ranked_search
        ORDER BY public.get_fuzzy_rank (
                title,
                to_tsquery(
                    'simple',
                    websearch_to_tsquery('english', search_query)::TEXT || ':*')::TEXT
                ) DESC;
    END IF;
END;
$$ LANGUAGE plpgsql;

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
CREATE INDEX idx_person_search ON public.person_search USING GIN ("search");

CREATE INDEX trgm_idx_gin_person_search ON public.person_search USING GIN ("name" gin_trgm_ops);

CREATE INDEX IF NOT EXISTS IX_person_search_pop_avg_and_imdb_rating ON public.person_search (
    popularity DESC
);

-----------------------------------------------------------------------------------------------------------------------
--person search function
CREATE OR REPLACE FUNCTION public.search_person_quick(search_query TEXT, user_id_v VARCHAR)
    RETURNS TABLE(
        person_id_v VARCHAR,
        name_v VARCHAR,
        primary_profession_v VARCHAR,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
BEGIN
    IF length(search_query) <= 2
    THEN
        RETURN;
    ELSEIF coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE            
        RETURN QUERY
            SELECT 
                person_id, "name", primary_profession, popularity, ts_headline(
                    'english', q.name, websearch_to_tsquery('english', search_query), 
                    'MaxFragments=3,MaxWords=25,MinWords=2') highlight, q."rank"
            FROM (
                    SELECT ts_rank(
                            f."search", websearch_to_tsquery('english', search_query)
                        ) 
                        + public.rank_boost_rating ((0.005*popularity), popularity, 5)
                        + public.rank_boost_recent_viewed(person_id, user_id_v)
                        + public.get_fuzzy_rank ("name", search_query) 
                        "rank", *
                    FROM public.person_search f, websearch_to_tsquery('english', search_query) AS tsq
                    WHERE
                        f."search" @@ to_tsquery('english', tsq::TEXT || ':*')
                ) q
            WHERE
                q.rank > 0.001
            ORDER BY "rank" DESC NULLS LAST;
    END IF;        
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION public.search_person_slow(search_query TEXT)
    RETURNS TABLE(
        person_id_v VARCHAR,
        name_v VARCHAR,
        primary_profession_v VARCHAR,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
        BEGIN
    IF length(search_query) <= 4
    THEN
        RETURN;
    ELSEIF
        coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE    
        RETURN QUERY
        WITH
            ranked_search AS (
                SELECT ts_rank(
                        "search", websearch_to_tsquery('english', search_query)
                    ) 
                    + public.rank_boost_rating ((0.05*popularity), popularity, 5)
                    "rank", person_id, "name", primary_profession, popularity
                FROM public.person_search
                ORDER BY "rank" DESC NULLS LAST
                LIMIT 1000
            )
        SELECT person_id, "name", primary_profession, popularity, 
            ts_headline(
                'english', "name", websearch_to_tsquery('english', search_query), 'MaxFragments=3,MaxWords=25,MinWords=2'
            ) highlight, "rank"
        FROM ranked_search
        ORDER BY public.get_fuzzy_rank (
                "name",
                to_tsquery(
                    'simple',
                    websearch_to_tsquery('english', search_query)::TEXT || ':*')::TEXT
                ) DESC;
    END IF;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------ALL SEARCH
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.search_all(search_query TEXT, user_id_v VARCHAR)
    RETURNS TABLE(
        type_s VARCHAR,
        id_s VARCHAR,
        title_s VARCHAR,
        poster_s VARCHAR,
        average_rating_s NUMERIC,
        imdb_rating_s NUMERIC,
        popularity_s BIGINT,
        highlight_s TEXT,
        rank_s DOUBLE PRECISION) AS $$  
BEGIN
    IF length(search_query) <= 2
    THEN
        RETURN;
    ELSEIF coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    END IF;

    IF EXISTS(
            SELECT true
            FROM public.search_movie_quick(search_query, user_id_v)
            WHERE rank_v > 0.8
            LIMIT 1
        )
    THEN 
        RETURN QUERY
            SELECT 
                'movieq'::varchar AS type_v, movie_id_v, title_v, poster_v, average_rating_v, imdb_rating_v, popularity_v, highlight_v, rank_v
            FROM public.search_movie_quick(search_query, user_id_v);
    ELSEIF EXISTS(
            SELECT true
            FROM public.search_series_quick(search_query, user_id_v)
            WHERE rank_v > 1
            LIMIT 1
        )
    THEN 
        RETURN QUERY
            SELECT 
                'seriesq'::varchar AS type_v, series_id_v, title_v, poster_v, average_rating_v, imdb_rating_v, popularity_v, highlight_v, rank_v
            FROM public.search_series_quick(search_query, user_id_v);
    ELSEIF EXISTS(
            SELECT true
            FROM public.search_episode_quick(search_query, user_id_v)
            WHERE rank_v > 1
            LIMIT 1
        )
    THEN 
        RETURN QUERY
            SELECT 
                'episodeq'::varchar AS type_v, episode_id_v, title_v, poster_v, average_rating_v, imdb_rating_v, popularity_v, highlight_v, rank_v
            FROM public.search_episode_quick(search_query, user_id_v);
    ELSEIF EXISTS(
        SELECT
            true
        FROM public.search_person_quick(search_query, user_id_v)
        WHERE rank_v > 1
        LIMIT 1
    )
    THEN
        RETURN QUERY
            SELECT
                'personq'::varchar AS type_v, person_id_v, name_v, ''::varchar, 0.0, 0.0, popularity_v, highlight_v, rank_v
            FROM public.search_person_quick(search_query, user_id_v);
    ELSEIF EXISTS(
            (SELECT
                true
            FROM public.search_movie_quick(search_query, user_id_v)
            LIMIT 1)
            UNION ALL
            (SELECT
                true
            FROM public.search_series_quick(search_query, user_id_v)
            LIMIT 1)
            UNION ALL
            (SELECT
                true
            FROM public.search_episode_quick(search_query, user_id_v)
            LIMIT 1)
            UNION ALL
            SELECT
                true
            FROM public.search_person_quick(search_query, user_id_v)
        LIMIT 1
        )
    THEN 
        RETURN QUERY
            SELECT
                'movieq'::varchar AS type_v, movie_id_v, title_v, poster_v, average_rating_v, imdb_rating_v, popularity_v, highlight_v, rank_v
            FROM public.search_movie_quick(search_query, user_id_v)
            UNION ALL
            SELECT
                'seriesq'::varchar AS type_v, series_id_v, title_v, poster_v, average_rating_v, imdb_rating_v, popularity_v, highlight_v, rank_v
            FROM public.search_series_quick(search_query, user_id_v)
            UNION ALL
            SELECT
                'episodeq'::varchar AS type_v, episode_id_v, title_v, poster_v, average_rating_v, imdb_rating_v, popularity_v, highlight_v, rank_v
            FROM public.search_episode_quick(search_query, user_id_v)
            UNION ALL
            SELECT
                'personq'::varchar AS type_v, person_id_v, name_v, ''::varchar, 0.0, 0.0, popularity_v, highlight_v, rank_v
            FROM public.search_person_quick(search_query, user_id_v)
        ORDER BY rank_v DESC NULLS LAST;
    ELSE
        RETURN QUERY
       (SELECT
            'movie'::varchar AS type_v,
            movie_id_v AS id_v,
            title_v,
            poster_v,
            average_rating_v, 
            imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_movie_slow(search_query)
        LIMIT 50)
        UNION ALL
        (SELECT
            'series'::varchar AS type_v,
            series_id_v AS id_v,
            title_v,
            poster_v,
            average_rating_v,
            imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_series_slow(search_query)
        LIMIT 50)
        UNION ALL
        (SELECT
            'episode'::varchar AS type_v,
            episode_id_v AS id_v,
            title_v,
            poster_v,
            average_rating_v,
            imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_episode_slow(search_query)
        LIMIT 50)
        UNION ALL
        (SELECT
            'person'::varchar AS type_v,
            person_id_v AS id_v,
            name_v,
            ''::varchar AS poster_v,
            0.0 AS average_rating_v,
            0.0 AS imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_person_slow(search_query)
        LIMIT 50);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT * 
FROM public.search_all('the biag short', 'ur00022837');

 with quick_com as (
        SELECT
            'movie' AS type_v,
            movie_id_v AS id_v,
            title_v,
            poster_v,
            average_rating_v, 
            imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_movie_slow('David Benioff')
        UNION ALL
        SELECT
            'series' AS type_v,
            series_id_v AS id_v,
            title_v,
            poster_v,
            average_rating_v,
            imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_series_slow('David Benioff')
        UNION ALL
        SELECT
            'episode' AS type_v,
            episode_id_v AS id_v,
            title_v,
            poster_v,
            average_rating_v,
            imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_episode_slow('David Benioff')
        UNION ALL
        SELECT
            'person' AS type_v,
            person_id_v AS id_v,
            name_v,
            '' AS poster_v,
            0 AS average_rating_v,
            0 AS imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_person_slow('David Benioff')
 )
SELECT * FROM quick_com
ORDER BY rank_v DESC NULLS LAST 



        SELECT
            true, 'movie' AS type_v
        FROM public.search_movie_quick('batman', 'ur00022837')
        WHERE rank_v > 0.8
        LIMIT 1;


        UNION
        SELECT
            true, 'series' AS type_v
        FROM public.search_series_quick('Battle', 'ur00022837')
        WHERE rank_v > 0.6
        UNION
        SELECT
            true, 'episode' AS type_v
        FROM public.search_episode_quick('Battle', 'ur00022837')
        WHERE rank_v > 0.9;


        SELECT
            'person' AS type_v,
            person_id_v AS id_v,
            name_v,
            '' AS poster_v,
            0 AS average_rating_v,
            0 AS imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_person_quick('Peter Din', 'ur00022837')
        WHERE rank_v > 0.2;
