-- Active: 1727253378954@@127.0.0.1@5532@portf_1
-------------------------------------------------------------------------------------------------
--Create user functions
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-- watchlist

CREATE OR REPLACE FUNCTION public.get_user_watchlist(user_id_v VARCHAR)
    RETURNS TABLE (title_id VARCHAR, title_type VARCHAR, title_of VARCHAR, 
    poster_of VARCHAR, average_r NUMERIC, imdb_r NUMERIC, watchlist_order BIGINT) AS $$
BEGIN
    RETURN QUERY
                WITH
            combined_user_whatch AS (
                SELECT
                    "user_id",
                    episode_id AS title_id_v,
                    watchlist AS watchlist_order_v
                FROM user_episode_watchlist
                WHERE
                    "user_id" = user_id_v
                UNION ALL
                SELECT
                    "user_id",
                    series_id AS title_id_v,
                    watchlist AS watchlist_order_v
                FROM user_series_watchlist
                WHERE
                    "user_id" = user_id_v
                UNION ALL
                SELECT
                    "user_id",
                    movie_id AS title_id_v,
                    watchlist AS watchlist_order_v
                FROM user_movie_watchlist
                WHERE
                    "user_id" = user_id_v
            ),
            combined_title AS (
                SELECT
                    episode_id AS title_id_v,
                    title,
                    poster,
                    average_rating,
                    imdb_rating,
                    'episode'::varchar AS title_type_v
                FROM episode
                WHERE
                    episode_id IN (
                        SELECT title_id_v
                        FROM combined_user_whatch
                    )
                UNION ALL
                SELECT
                    series_id AS title_id_v,
                    title,
                    poster,
                    average_rating,
                    imdb_rating,
                    'series'::varchar AS title_type_v
                FROM series
                WHERE
                    series_id IN (
                        SELECT title_id_v
                        FROM combined_user_whatch
                    )
                UNION ALL
                SELECT
                    movie_id AS title_id_v,
                    title,
                    poster,
                    average_rating,
                    imdb_rating,
                    'movie'::varchar AS title_type_v
                FROM movie
                WHERE
                    movie_id IN (
                        SELECT title_id_v
                        FROM combined_user_whatch
                    )
            )
        SELECT
            title_id_v,
            title_type_v,
            title,
            poster,
            average_rating,
            imdb_rating,
            watchlist_order_v
        FROM
            combined_user_whatch
            NATURAL JOIN combined_title
        ORDER BY watchlist_order_v ASC; 
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------------------------
-- rating

CREATE OR REPLACE FUNCTION public.get_user_rating(user_id_v VARCHAR)
    RETURNS TABLE (title_id VARCHAR, title_type VARCHAR, title_of VARCHAR, 
    poster_of VARCHAR, average_r NUMERIC, imdb_r NUMERIC, user_rating SMALLINT) AS $$
BEGIN
    RETURN QUERY
                WITH
            combined_user_rating AS (
                SELECT
                    "user_id",
                    episode_id AS title_id_v,
                    rating AS user_rating_v
                FROM user_episode_rating
                WHERE
                    "user_id" = user_id_v
                UNION ALL
                SELECT
                    "user_id",
                    series_id AS title_id_v,
                    rating AS user_rating_v
                FROM user_series_rating
                WHERE
                    "user_id" = user_id_v
                UNION ALL
                SELECT
                    "user_id",
                    movie_id AS title_id_v,
                    rating AS user_rating_v
                FROM user_movie_rating
                WHERE
                    "user_id" = user_id_v
            ),
            combined_title AS (
                SELECT
                    episode_id AS title_id_v,
                    title,
                    poster,
                    average_rating,
                    imdb_rating,
                    'episode'::varchar AS title_type_v
                FROM episode
                WHERE
                    episode_id IN (
                        SELECT title_id_v
                        FROM combined_user_rating
                    )
                UNION ALL
                SELECT
                    series_id AS title_id_v,
                    title,
                    poster,
                    average_rating,
                    imdb_rating,
                    'series'::varchar AS title_type_v
                FROM series
                WHERE
                    series_id IN (
                        SELECT title_id_v
                        FROM combined_user_rating
                    )
                UNION ALL
                SELECT
                    movie_id AS title_id_v,
                    title,
                    poster,
                    average_rating,
                    imdb_rating,
                    'movie'::varchar AS title_type_v
                FROM movie
                WHERE
                    movie_id IN (
                        SELECT title_id_v
                        FROM combined_user_rating
                    )
            )
        SELECT
            title_id_v,
            title_type_v,
            title,
            poster,
            average_rating,
            imdb_rating,
            user_rating_v
        FROM
            combined_user_rating
            NATURAL JOIN combined_title
        ORDER BY user_rating_v DESC; 
END;
$$ LANGUAGE plpgsql;

--------------------------------------------------recent_view------------------------------------------------------------
CREATE OR REPLACE FUNCTION Public.get_user_recent_view(user_id_v VARCHAR)
    RETURNS TABLE (type_id_of VARCHAR, "type" VARCHAR, title_of VARCHAR, 
    poster_of VARCHAR, average_r NUMERIC, imdb_r NUMERIC, view_order BIGINT) AS $$
BEGIN
    RETURN QUERY
                WITH
            recent_view_filtered AS (
                SELECT
                    "user_id",
                    "type_id" as type_id_v,
                    view_ordering
                FROM recent_view
                WHERE
                    "user_id" = user_id_v
            ),
            combined_type AS (
                SELECT
                    episode_id AS type_id_v,
                    title,
                    poster,
                    average_rating,
                    imdb_rating,
                    'episode'::varchar AS title_type_v
                FROM episode
                WHERE
                    episode_id IN (
                        SELECT type_id_v
                        FROM recent_view_filtered 
                    )
                UNION ALL
                SELECT
                    series_id AS type_id_v,
                    title,
                    poster,
                    average_rating,
                    imdb_rating,
                    'series'::varchar AS title_type_v
                FROM series
                WHERE
                    series_id IN (
                        SELECT type_id_v
                        FROM recent_view_filtered 
                    )
                UNION ALL
                SELECT
                    movie_id AS type_id_v,
                    title,
                    poster,
                    average_rating,
                    imdb_rating,
                    'movie'::varchar AS title_type_v
                FROM movie
                WHERE
                    movie_id IN (
                        SELECT type_id_v
                        FROM recent_view_filtered
                    )
                UNION ALL
                SELECT
                    person_id AS type_id_v,
                    "name" AS title,
                    NULL AS poster,
                    0::NUMERIC AS average_rating,
                    0::NUMERIC AS imdb_rating,
                    'person'::varchar AS title_type_v
                FROM person
                WHERE
                    person_id IN (
                        SELECT type_id_v
                        FROM recent_view_filtered
                    )
            )
        SELECT
            type_id_v,
            title_type_v,
            title,
            poster,
            average_rating,
            imdb_rating,
            view_ordering
        FROM
            recent_view_filtered 
            NATURAL JOIN combined_type
        ORDER BY view_ordering DESC;
END;
$$ LANGUAGE plpgsql;