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
RETURNS TABLE(
    episode_id_of VARCHAR, title_of VARCHAR, 
    poster_of VARCHAR, average_r NUMERIC, imdb_r NUMERIC, popularity_of BIGINT
) AS $$ 
    BEGIN
        RETURN QUERY 
            SELECT
                episode_id,
                title,
                poster,
                average_rating,
                imdb_rating,
                popularity
            FROM episode_genre NATURAL JOIN episode
            WHERE genre_name = genre_name_v;
    END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------movie genre functions-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_genre_movies(genre_name_v VARCHAR(256))
RETURNS TABLE(
    movie_id_of VARCHAR, title_of VARCHAR, 
    poster_of VARCHAR, average_r NUMERIC, imdb_r NUMERIC, popularity_of BIGINT
) AS $$
    BEGIN
        RETURN QUERY 
            SELECT
                movie_id,
                title,
                poster,
                average_rating,
                imdb_rating,
                popularity
            FROM movie_genre NATURAL JOIN movie
            WHERE genre_name = genre_name_v;
    END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------series genre functions-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_genre_series(genre_name_v VARCHAR(256))
RETURNS TABLE(
    series_id_of VARCHAR, title_of VARCHAR, 
    poster_of VARCHAR, average_r NUMERIC, imdb_r NUMERIC, popularity_of BIGINT
) AS $$
    BEGIN
        RETURN QUERY 
            SELECT
                series_id,
                title,
                poster,
                average_rating,
                imdb_rating,
                popularity
            FROM series_genre NATURAL JOIN series
            WHERE genre_name = genre_name_v;
    END;
$$ LANGUAGE plpgsql;