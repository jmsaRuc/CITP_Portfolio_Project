DROP TRIGGER IF EXISTS after_insert_episode ON episode;
DROP TRIGGER IF EXISTS after_insert_series ON series;

DROP FUNCTION IF EXISTS create_episode_type_after_insert CASCADE;
DROP FUNCTION IF EXISTS create_series_type_after_insert CASCADE;

DROP FUNCTION IF EXISTS create_movie_type_after_insert CASCADE;

DROP TRIGGER IF EXISTS after_insert_movie ON movie;
DROP FUNCTION IF EXISTS create_type_after_insert CASCADE;

DROP TRIGGER IF EXISTS after_delete_episode ON episode;
DROP TRIGGER IF EXISTS after_delete_series ON series;

DROP FUNCTION IF EXISTS delete_episode_type_after_delete CASCADE;
DROP FUNCTION IF EXISTS delete_series_type_after_delete CASCADE;

DROP TRIGGER IF EXISTS after_delete_movie ON movie;
DROP FUNCTION IF EXISTS delete_movie_type_after_delete CASCADE;

DROP FUNCTION IF EXISTS create_movie_type_after_insert CASCADE;

DROP FUNCTION IF EXISTS create_movie_type_after_insert CASCADE;


DROP TRIGGER IF EXISTS after_insert_recent_view ON public.recent_view;   

DROP FUNCTION IF EXISTS public.update_popularity_after_insert CASCADE;

DROP TRIGGER IF EXISTS after_delet_recent_view ON public.recent_view;

DROP FUNCTION IF EXISTS update_popularity_after_delete CASCADE;


DROP TRIGGER IF EXISTS after_insert_movie_rating ON public.user_movie_rating;

DROP FUNCTION IF EXISTS update_movie_average_rating_after_insert CASCADE;

DROP TRIGGER IF EXISTS after_insert_episode_rating ON public.user_episode_rating;

DROP FUNCTION IF EXISTS update_episode_average_rating_after_insert CASCADE;

DROP TRIGGER IF EXISTS after_insert_series_rating ON public.user_series_rating;

DROP FUNCTION IF EXISTS update_series_average_rating_after_insert CASCADE;

DROP TRIGGER IF EXISTS after_delete_movie_rating ON public.user_movie_rating;

DROP FUNCTION IF EXISTS update_movie_average_rating_after_delete CASCADE;

DROP TRIGGER IF EXISTS after_delete_episode_rating ON public.user_episode_rating;

DROP FUNCTION IF EXISTS update_episode_average_rating_after_delete CASCADE;

DROP TRIGGER IF EXISTS after_delete_series_rating ON public.user_series_rating;

DROP FUNCTION IF EXISTS update_series_average_rating_after_delete CASCADE;

DROP FUNCTION IF EXISTS update_movie_average_rating_after_update CASCADE;

DROP FUNCTION IF EXISTS public.refresh_if_new_day CASCADE;

DROP TRIGGER IF EXISTS after_insert_refresh_top_this_week ON public.recent_view; 