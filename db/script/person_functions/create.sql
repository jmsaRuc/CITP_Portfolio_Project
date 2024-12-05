
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
                AND "role" = 'actor'
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
                AND "role" = 'actor'
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
                AND "role" = 'actor'
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


