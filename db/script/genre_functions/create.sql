-----------------------------------------------------------------------main genre functions-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_all_genres()
RETURNS TABLE(
    genre_name_of VARCHAR(256)
) AS $$
    BEGIN
        RETURN QUERY 
            SELECT DISTINCT genre_name
            FROM episode_genre
                            UNION
            SELECT DISTINCT genre_name
             FROM movie_genre
                            UNION
            SELECT DISTINCT genre_name
            FROM series_genre
            ORDER BY genre_name;  
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.get_genre(genre_name_v VARCHAR(256)) 
RETURNS TABLE(
    genre_name_of VARCHAR(256),
    episode_amount INT,
    movie_amount INT,
    series_amount INT,
    total_amount INT
) AS $$
    DECLARE
        episode_count INT;
        movie_count INT;
        series_count INT;
        total_count INT;
    BEGIN
        SELECT COUNT(*) INTO episode_count 
        FROM episode_genre 
        WHERE genre_name = genre_name_v;

        SELECT COUNT(*) INTO movie_count 
        FROM movie_genre 
        WHERE genre_name = genre_name_v;

        SELECT COUNT(*) INTO series_count 
        FROM series_genre
        WHERE genre_name = genre_name_v;

        total_count := episode_count + movie_count + series_count;

        RETURN QUERY SELECT genre_name_v, episode_count, movie_count, series_count, total_count;
    END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------episode genre functions-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_genre_episodes(genre_name_v VARCHAR(256))
RETURNS TABLE(LIKE public.episode
) AS $$
    BEGIN
        RETURN QUERY 
            SELECT *
            FROM (SELECT episode_id FROM episode_genre WHERE genre_name = genre_name_v) NATURAL JOIN episode;
    END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------movie genre functions-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_genre_movies(genre_name_v VARCHAR(256))
RETURNS TABLE(LIKE public.movie
) AS $$
    BEGIN
        RETURN QUERY 
            SELECT *
            FROM (SELECT movie_id FROM movie_genre WHERE genre_name = genre_name_v) NATURAL JOIN movie;
    END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------series genre functions-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_genre_series(genre_name_v VARCHAR(256))
RETURNS TABLE(LIKE public.series
) AS $$
    BEGIN
        RETURN QUERY 
            SELECT *
            FROM (SELECT series_id FROM series_genre WHERE genre_name = genre_name_v) NATURAL JOIN series;
    END;
$$ LANGUAGE plpgsql;