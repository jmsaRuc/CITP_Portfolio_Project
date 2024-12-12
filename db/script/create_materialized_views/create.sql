-----------------------------top this week ---------------------------------------------

CREATE MATERIALIZED VIEW IF NOT EXISTS public.top_this_week AS
WITH
    recent_view_filter_week AS (
        SELECT "type_id", count("type_id") AS popularity
        FROM public.recent_view
        WHERE
            created_at BETWEEN now() - INTERVAL '7 days' AND now()
        GROUP BY
            "type_id"
    ),
    recent_view_get_created_at AS (
        SELECT
            "type_id" AS type_id_v,
            popularity,
            (
                SELECT max(created_at)
                FROM public.recent_view AS r
                WHERE
                    r.type_id = "type_id"
            ) AS pop_created_at
        FROM recent_view_filter_week
    ),
    combined_type AS (
        SELECT
            episode_id AS type_id_v,
            title,
            poster,
            average_rating,
            imdb_rating,
            'episode'::varchar AS title_type_v
        FROM public.episode
        WHERE
            episode_id IN (
                SELECT type_id_v
                FROM recent_view_get_created_at
            )
        UNION ALL
        SELECT
            series_id AS type_id_v,
            title,
            poster,
            average_rating,
            imdb_rating,
            'series'::varchar AS title_type_v
        FROM public.series
        WHERE
            series_id IN (
                SELECT type_id_v
                FROM recent_view_get_created_at
            )
        UNION ALL
        SELECT
            movie_id AS type_id_v,
            title,
            poster,
            average_rating,
            imdb_rating,
            'movie'::varchar AS title_type_v
        FROM public.movie
        WHERE
            movie_id IN (
                SELECT type_id_v
                FROM recent_view_get_created_at
            )
    )
SELECT
    type_id_v,
    title_type_v,
    title,
    poster,
    average_rating,
    imdb_rating,
    popularity,
    pop_created_at
FROM
    recent_view_get_created_at
    NATURAL JOIN combined_type
WITH
    NO DATA;

REFRESH MATERIALIZED VIEW public.top_this_week;
