
-----------------------------------------------------------------------------------------top_actors-----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_top_actors_in_movie(movie_id_v VARCHAR(10))
    RETURNS TABLE (person_id_v VARCHAR(10), name_v VARCHAR(256), character_v TEXT) AS $$
BEGIN
    RETURN QUERY
    WITH
        in_movie AS (
            SELECT person_id, "character"
            FROM public.is_in_movie
            WHERE
                movie_id = movie_id_v
                AND "role" = 'actor'
            ORDER BY cast_order ASC
        ),
        persons_in AS (
            SELECT person_id, "name"
            FROM person
            WHERE
                person_id IN (
                    SELECT person_id
                    FROM in_movie
                )
        )
    SELECT r.person_id, "name", "character"
    FROM in_movie AS r
        JOIN persons_in ON r.person_id = persons_in.person_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.get_top_actors_in_series(series_id_v VARCHAR(10))
    RETURNS TABLE (person_id_v VARCHAR(10), name_v VARCHAR(256), character_v TEXT) AS $$
BEGIN
    RETURN QUERY
    WITH
        in_series AS (
            SELECT person_id, "character"
            FROM public.is_in_series
            WHERE
                series_id = series_id_v
                AND "role" = 'actor'
            ORDER BY cast_order ASC
        ),
        persons_in AS (
            SELECT person_id, "name"
            FROM person
            WHERE
                person_id IN (
                    SELECT person_id
                    FROM in_series
                )
        )
    SELECT r.person_id, "name", "character"
    FROM in_series AS r
        JOIN persons_in ON r.person_id = persons_in.person_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.get_top_actors_in_episode(episode_id_v VARCHAR(10))
    RETURNS TABLE (person_id_v VARCHAR(10), name_v VARCHAR(256), character_v TEXT) AS $$
BEGIN
    RETURN QUERY
    WITH
        in_episode AS (
            SELECT person_id, "character"
            FROM public.is_in_episode
            WHERE
                episode_id = episode_id_v
                AND "role" = 'actor'
            ORDER BY cast_order ASC
        ),
        persons_in AS (
            SELECT person_id, "name"
            FROM person
            WHERE
                person_id IN (
                    SELECT person_id
                    FROM in_episode
                )
        )
    SELECT r.person_id, "name", "character"
    FROM in_episode AS r
        JOIN persons_in ON r.person_id = persons_in.person_id;
END;
$$ LANGUAGE plpgsql;


