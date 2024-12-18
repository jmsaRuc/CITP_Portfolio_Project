------------------------------------get person credit------------------------------------
CREATE OR REPLACE FUNCTION public.get_person_credit(person_id_v VARCHAR(10))
    RETURNS TABLE (title_id_v VARCHAR, title_v VARCHAR, title_type_v VARCHAR, poster_v VARCHAR, 
    character_v TEXT, imdb_rating_v NUMERIC, re_year_v VARCHAR, popularity_v BIGINT) AS $$
    BEGIN
        RETURN QUERY
        with filt_in as (
                SELECT
                    episode_id AS title_id_v,
                    title AS title_v,
                    'episode'::varchar AS title_type_v,
                    poster as poster_v,
                    "character" as character_v,
                    imdb_rating as imdb_rating_v,
                    re_year as re_year_v,
                    popularity as popularity_v
                FROM is_in_episode NATURAL JOIN public.episode
                WHERE
                    person_id = person_id_v 
                    AND cast_order <= 10
                UNION ALL
                SELECT
                    series_id AS title_id_v,
                    title AS title_v,
                    'series'::varchar AS title_type_v,
                    poster as poster_v,
                    "character" as character_v,
                    imdb_rating as imdb_rating_v,
                    start_year as re_year_v,
                    popularity as popularity_v
                FROM is_in_series NATURAL JOIN public.series
                WHERE
                    person_id = person_id_v 
                    AND cast_order <= 10
                UNION ALL
                SELECT
                    movie_id AS title_id_v,
                    title AS title_v,
                    'movie'::varchar AS title_type_v,
                    poster as poster_v,
                    "character" as character_v,
                    imdb_rating as imdb_rating_v,
                    re_year as re_year_v,
                    popularity as popularity_v
                FROM is_in_movie NATURAL JOIN public.movie
                WHERE
                    person_id = person_id_v 
                    AND cast_order <= 10
            )
            SELECT *
            FROM filt_in;
    END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------------------------top_actors-----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_top_actors_in_movie(movie_id_v VARCHAR(10))
    RETURNS TABLE (person_id_v VARCHAR(10), name_v VARCHAR(256), character_v TEXT, cast_order_v BIGINT) AS $$
BEGIN
    RETURN QUERY
    WITH
        in_movie AS (
            SELECT person_id, "character", cast_order
            FROM public.is_in_movie
            WHERE
                movie_id = movie_id_v
                AND ("role" = 'actor' or "role" = 'actress')
        ),
        persons_in AS (
            SELECT person_id, "name"
            FROM public.person
            WHERE
                person_id IN (
                    SELECT person_id
                    FROM in_movie
                )
        )
    SELECT person_id, "name", "character", cast_order
    FROM in_movie NATURAL JOIN persons_in
    ORDER BY cast_order ASC;    
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.get_top_actors_in_series(series_id_v VARCHAR(10))
    RETURNS TABLE (person_id_v VARCHAR(10), name_v VARCHAR(256), character_v TEXT, cast_order_v BIGINT) AS $$
BEGIN
    RETURN QUERY
    WITH
        in_series AS (
            SELECT person_id, "character", cast_order
            FROM public.is_in_series
            WHERE
                series_id = series_id_v
                AND ("role" = 'actor' or "role" = 'actress')
        ),
        persons_in AS (
            SELECT person_id, "name"
            FROM public.person
            WHERE
                person_id IN (
                    SELECT person_id
                    FROM in_series
                )
        )
    SELECT person_id, "name", "character", cast_order
    FROM in_series NATURAL JOIN persons_in
    ORDER BY cast_order ASC;    
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.get_top_actors_in_episode(episode_id_v VARCHAR(10))
    RETURNS TABLE (person_id_v VARCHAR(10), name_v VARCHAR(256), character_v TEXT, cast_order_v BIGINT) AS $$
BEGIN
    RETURN QUERY
    WITH
        in_episode AS (
            SELECT person_id, "character", cast_order
            FROM public.is_in_episode
            WHERE
                episode_id = episode_id_v
                AND ("role" = 'actor' or "role" = 'actress')
        ),
        persons_in AS (
            SELECT person_id, "name"
            FROM public.person
            WHERE
                person_id IN (
                    SELECT person_id
                    FROM in_episode
                )
        )
    SELECT person_id, "name", "character", cast_order
    FROM in_episode NATURAL JOIN persons_in
    ORDER BY cast_order ASC;     
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------get writers movie----------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_writers_in_movie(movie_id_v VARCHAR(10))
    RETURNS TABLE (person_id_v VARCHAR(10), name_v VARCHAR(256), "role_v" VARCHAR(50), job_v TEXT, cast_order_v BIGINT) AS $$
BEGIN
    RETURN QUERY
        with is_in_with_order as (
        SELECT movie_id, person_id, "role", job, "character", cast_order
        FROM is_in_movie
        WHERE movie_id = movie_id_v and ("role" = 'writer' or job = 'writen by')
    )
    SELECT person_id, "name", "role", job, cast_order
    FROM is_in_with_order NATURAL join public.person
    ORDER BY cast_order ASC;  
END;
$$ LANGUAGE plpgsql;



---------------------------------------------------------------get writers series----------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_writers_in_series(series_id_v VARCHAR(10))
    RETURNS TABLE (person_id_v VARCHAR(10), name_v VARCHAR(256), "role_v" VARCHAR(50), job_v TEXT, cast_order_v BIGINT) AS $$
BEGIN
    RETURN QUERY
        with is_in_with_order as (
        SELECT series_id, person_id, "role", job, "character", cast_order
        FROM is_in_series
        WHERE series_id = series_id_v and ("role" = 'writer' or job = 'writen by')
    )
    SELECT person_id, "name", "role", job, cast_order
    FROM is_in_with_order NATURAL join public.person
    ORDER BY cast_order ASC;  
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------get writers episode----------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_writers_in_episode(episode_id_v VARCHAR(10))
    RETURNS TABLE (person_id_v VARCHAR(10), name_v VARCHAR(256), "role_v" VARCHAR(50), job_v TEXT, cast_order_v BIGINT) AS $$
BEGIN
    RETURN QUERY
        with is_in_with_order as (
        SELECT episode_id, person_id, "role", job, "character", cast_order
        FROM is_in_episode
        WHERE episode_id = episode_id_v and ("role" = 'writer' or job = 'writen by')
    )
    SELECT person_id, "name", "role", job, cast_order
    FROM is_in_with_order NATURAL join public.person
    ORDER BY cast_order ASC;  
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------get director movie----------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_director_in_movie(movie_id_v VARCHAR(10))
    RETURNS TABLE (person_id_v VARCHAR(10), name_v VARCHAR(256), "role_v" VARCHAR(50), job_v TEXT, cast_order_v BIGINT) AS $$
BEGIN
    RETURN QUERY
        with is_in_with_order as (
        SELECT movie_id, person_id, "role", job, "character", cast_order
        FROM is_in_movie
        WHERE movie_id = movie_id_v and ("role" = 'director' or job = 'directed by')
    )
    SELECT person_id, "name", "role", job, cast_order
    FROM is_in_with_order NATURAL join public.person
    ORDER BY cast_order ASC;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------get creator series----------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_creator_in_series(series_id_v VARCHAR(10))
    RETURNS TABLE (person_id_v VARCHAR(10), name_v VARCHAR(256), "role_v" VARCHAR(50), job_v TEXT, cast_order_v BIGINT) AS $$
BEGIN
    RETURN QUERY
        with is_in_with_order as (
        SELECT series_id, person_id, "role", job, "character", cast_order
        FROM is_in_series
        WHERE series_id = series_id_v and ("role" = 'writer' and job = 'created by')
    )
    SELECT person_id, "name", "role", job, cast_order
    FROM is_in_with_order NATURAL join public.person
    ORDER BY cast_order ASC;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------get director episode----------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_director_in_episode(episode_id_v VARCHAR(10))
    RETURNS TABLE (person_id_v VARCHAR(10), name_v VARCHAR(256), "role_v" VARCHAR(50), job_v TEXT, cast_order_v BIGINT) AS $$
BEGIN
    RETURN QUERY
        with is_in_with_order as (
        SELECT episode_id, person_id, "role", job, "character", cast_order
        FROM is_in_episode
        WHERE episode_id = episode_id_v and ("role" = 'director' or job = 'directed by')
    )
    SELECT person_id, "name", "role", job, cast_order
    FROM is_in_with_order NATURAL join public.person
    ORDER BY cast_order ASC;
END;
$$ LANGUAGE plpgsql;