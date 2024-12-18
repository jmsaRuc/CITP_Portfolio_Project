----------------get episodes in series----------------
CREATE OR REPLACE FUNCTION public.get_episodes_in_series(series_id_v VARCHAR(10), season_number_sort INT)
    RETURNS TABLE (episode_id_v VARCHAR(10), title_v VARCHAR(256), poster_v VARCHAR(180), plot_v TEXT, relese_date_v DATE, 
    season_number_v BIGINT, episode_number_v BIGINT, average_rating_v NUMERIC(5,1), imdb_rating_v NUMERIC(5,1), popularity_v BIGINT) AS $$
BEGIN
    IF season_number_sort < 1 or season_number_sort is NULL 
    THEN
        RETURN QUERY
            SELECT episode_id, title, poster, plot, relese_date, season_number, episode_number, average_rating, imdb_rating, popularity
            FROM public.episode NATURAL JOIN episode_series
            WHERE series_id = series_id_v
            ORDER BY season_number ASC, episode_number ASC;
    ELSE
        RETURN QUERY
            SELECT episode_id, title, poster, plot, relese_date, season_number, episode_number, average_rating, imdb_rating, popularity
            FROM public.episode NATURAL JOIN episode_series
            WHERE series_id = series_id_v and season_number = season_number_sort
            ORDER BY episode_number ASC;
    END IF;
END;
$$ LANGUAGE plpgsql;