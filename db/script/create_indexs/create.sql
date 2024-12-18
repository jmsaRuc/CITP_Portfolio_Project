-----------------------------------------user created at ----------------------------------------------------
CREATE INDEX IF NOT EXISTS IX_user_created_at
ON public."user" (created_at DESC);

-----------------------------------------pop/avg_r/img_r----------------------------------------------------
CREATE INDEX IF NOT EXISTS IX_episode_pop_avg_and_imdb_rating 
ON public.episode (popularity DESC, average_rating DESC, imdb_rating DESC, relese_date DESC);

CREATE INDEX IF NOT EXISTS IX_movie_pop_avg_and_imdb_rating
ON public.movie (popularity DESC, average_rating DESC, imdb_rating DESC, release_date DESC);

CREATE INDEX IF NOT EXISTS IX_series_pop_avg_and_imdb_rating
ON public.series (popularity DESC, average_rating DESC, imdb_rating DESC, start_year DESC);

CREATE INDEX IF NOT EXISTS IX_person_pop
ON public.person (popularity DESC);

-------------------------------------------cast order------------------------------------------------------

CREATE INDEX IF NOT EXISTS IX_is_in_movie_cast_order
ON public.is_in_movie (cast_order ASC);

CREATE INDEX IF NOT EXISTS IX_is_in_series_cast_order
ON public.is_in_series (cast_order ASC);

CREATE INDEX IF NOT EXISTS IX_is_in_episode_cast_order
ON public.is_in_episode (cast_order ASC);

------------------------------------------user rating-----------------------------------------------------

CREATE INDEX IF NOT EXISTS IX_user_rating_movie_rating
ON public.user_movie_rating (rating DESC);

CREATE INDEX IF NOT EXISTS IX_user_rating_series_rating
ON public.user_series_rating (rating DESC);

CREATE INDEX IF NOT EXISTS IX_user_rating_episode_rating
ON public.user_episode_rating (rating DESC);

------------------------------------------user watchlist------------------------------------------------------

CREATE INDEX IF NOT EXISTS IX_user_watchlist_episode_watchlist
ON public.user_episode_watchlist (watchlist ASC);

CREATE INDEX IF NOT EXISTS IX_user_watchlist_series_watchlist
ON public.user_series_watchlist (watchlist ASC);

CREATE INDEX IF NOT EXISTS IX_user_watchlist_movie_watchlist
ON public.user_movie_watchlist (watchlist ASC);

------------------------------------------recent view------------------------------------------------------

CREATE INDEX IF NOT EXISTS IX_recent_view_view_ordering
ON public.recent_view (view_ordering DESC, created_at DESC);

------------------------------------------top this week (materilized_views)------------------------------------------------------

CREATE INDEX IF NOT EXISTS IX_T_week_pop_avg_and_imdb_rating
ON public.top_this_week (popularity DESC, pop_created_at DESC, average_rating DESC, imdb_rating DESC);

CREATE UNIQUE INDEX IF NOT EXISTS IX_T_week_type_id
ON public.top_this_week (type_id_v);