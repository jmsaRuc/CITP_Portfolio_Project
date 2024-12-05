-----------------------------------------pop/avg_r/img_r----------------------------------------------------
CREATE INDEX IF NOT EXISTS IX_episode_pop_avg_and_imdb_rating 
ON public.episode (popularity DESC, average_rating DESC, imdb_rating DESC);

CREATE INDEX IF NOT EXISTS IX_movie_pop_avg_and_imdb_rating
ON public.movie (popularity DESC, average_rating DESC, imdb_rating DESC);

CREATE INDEX IF NOT EXISTS IX_series_pop_avg_and_imdb_rating
ON public.series (popularity DESC, average_rating DESC, imdb_rating DESC);

CREATE INDEX IF NOT EXISTS IX_person_pop
ON public.person (popularity DESC);