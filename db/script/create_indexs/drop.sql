
DROP INDEX if EXISTS public."ix_user_created_at";
DROP INDEX if EXISTS public."ix_movie_pop_avg_and_imdb_rating";

DROP INDEX if EXISTS public."ix_episode_pop_avg_and_imdb_rating";

DROP INDEX if EXISTS public."ix_movie_pop_avg_and_imdb_rating";

DROP INDEX if EXISTS public."ix_series_pop_avg_and_imdb_rating";

DROP INDEX if EXISTS public."ix_person_pop";

DROP INDEX if EXISTS public."ix_is_in_movie_cast_order";

DROP INDEX if EXISTS public."ix_is_in_series_cast_order";

DROP INDEX if EXISTS public."ix_is_in_episode_cast_order";

DROP INDEX if EXISTS public."ix_user_rating_movie_rating";

DROP INDEX if EXISTS public."ix_user_rating_series_rating";

DROP INDEX if EXISTS public."ix_user_rating_episode_rating";

DROP INDEX if EXISTS public."ix_user_watchlist_episode_watchlist";

DROP INDEX if EXISTS public."ix_user_watchlist_series_watchlist";

DROP INDEX if EXISTS public."ix_user_watchlist_movie_watchlist";

DROP INDEX if EXISTS public."ix_recent_view_view_ordering";

DROP INDEX if EXISTS public."ix_t_week_pop_avg_and_imdb_rating";

DROP INDEX if EXISTS public."ix_t_week_type_id";