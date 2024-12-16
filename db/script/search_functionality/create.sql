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
        select case when popularity < voteThreshold or relase_date is NULL then 0 else (1/((now_date - relase_date)/365+1)*0.05) end;
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
CREATE OR REPLACE FUNCTION public.rank_boost_recent_viewed(movie_id_v VARCHAR, user_id_v VARCHAR)
    RETURNS NUMERIC AS $$
    BEGIN
        if EXISTS(
                SELECT
                    TRUE
                FROM recent_view
                WHERE
                "user_id" = user_id_v and "type_id" = movie_id_v
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

---------------------------------------------------------------
--movie
---------------------------------------------------------------
CREATE TABLE public.test_movie_keywords AS TABLE public.movie;

ALTER TABLE IF EXISTS public.test_movie_keywords
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
UPDATE public.test_movie_keywords AS s
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
UPDATE public.test_movie_keywords AS s
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
UPDATE public.test_movie_keywords AS s
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
            "name" as name_d,
            "character" as char_d,
            cast_order
        FROM in_movie
            NATURAL JOIN persons_in 
        ORDER BY
            cast_order ASC    
    ),
    arg AS (
        SELECT movie_id AS f, string_agg(name_d::TEXT, ',') AS actors_name, string_agg(char_d::TEXT, ',') AS actors_characters
        FROM get_name
        GROUP BY
            movie_id
    )
UPDATE public.test_movie_keywords AS s
SET
    top_actors_name = arg.actors_name,
    top_actors_character = arg.actors_characters
FROM arg
WHERE
    arg.f = s.movie_id; 

---------------------------------add language to movie search
with arg as (
    SELECT movie_id AS f, string_agg("language"::TEXT, ',') AS lang
    FROM public.movie_language
    GROUP BY movie_id
)
UPDATE public.test_movie_keywords AS s
SET
    "language" = arg.lang
FROM arg
WHERE
    arg.f = s.movie_id;



------------send search text to vector    

ALTER TABLE IF EXISTS public.test_movie_keywords
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
        'C'
    ) || ' ' || setweight(
        to_tsvector(
            'simple',
            coalesce(writers, '')
        ),
        'D'
    )
    || '' || setweight(
        to_tsvector(
            'simple',
            coalesce(top_actors_name, '')
        ),
        'D'
    )
    || '' || setweight(
        to_tsvector(
            'simple',
            coalesce(top_actors_character, '')
        ),
        'B'
    )
) STORED;

--create indexes
CREATE INDEX idx_search ON public.test_movie_keywords USING GIN (SEARCH);

CREATE INDEX trgm_idx_gin ON test_movie_keywords USING GIN (title gin_trgm_ops);

CREATE INDEX IF NOT EXISTS IX_movie_pop_avg_and_imdb_rating ON public.test_movie_keywords (popularity DESC);

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
        highlight_v TEXT) AS $$
BEGIN
    IF length(search_query) <= 2
    THEN
        RETURN;
    ELSE
        RETURN QUERY
            SELECT 
                movie_id, title, poster, average_rating, imdb_rating, popularity, ts_headline(
                    'english', q.title, websearch_to_tsquery('english', search_query), 
                    'MaxFragments=3,MaxWords=25,MinWords=2') highlight
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
                    FROM public.test_movie_keywords f, websearch_to_tsquery('english', search_query) AS tsq
                    WHERE
                        f."search" @@ to_tsquery('english', CONCAT(tsq::TEXT, websearch_to_tsquery('simple', search_query)) || ':*')
                ) q
            WHERE
                q.rank > 0.001
            ORDER BY RANK DESC NULLS LAST;
    END IF;        
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_movie_slow(search_query TEXT, user_id_v VARCHAR)
    RETURNS TABLE(
        movie_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT) AS $$
BEGIN
     IF length(search_query) <= 4
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
                    FROM public.test_movie_keywords
                    ORDER BY RANK DESC NULLS LAST
                    LIMIT 1000
                )
            SELECT movie_id, title, poster, average_rating, imdb_rating, popularity, 
                ts_headline(
                    'english', title, websearch_to_tsquery('english', search_query), 'MaxFragments=3,MaxWords=25,MinWords=2'
                ) Highlight
            FROM ranked_search
            ORDER BY public.get_fuzzy_rank (
                    title,
                    to_tsquery(
                        'english',
                        CONCAT(
                            websearch_to_tsquery('english', search_query)::TEXT, 
                            websearch_to_tsquery('simple', search_query)
                        )  || ':*')::TEXT
                    ) DESC;

    END IF;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM search_movie_quick('the ', 'ur00016377');
SELECT * FROM search_movie_slow('the bug sort', 'ur00016377');
        ------------------------series
------------------------episode

----------------------all