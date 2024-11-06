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


DROP FUNCTION IF EXISTS public.update_popularity_after_insert CASCADE;
DROP TRIGGER IF EXISTS after_insert_recent_view ON public.recent_view;   

DROP FUNCTION IF EXISTS public.update_popularity_after_insert CASCADE;

DROP TRIGGER IF EXISTS after_delet_recent_view ON public.recent_view;