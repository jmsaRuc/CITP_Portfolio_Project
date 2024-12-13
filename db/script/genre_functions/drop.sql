
DROP FUNCTION IF EXISTS public.get_all_genres();
DROP FUNCTION IF EXISTS public.get_genre(genre_name_v VARCHAR(256));

DROP FUNCTION IF EXISTS public.get_genre_episodes(genre_name_v VARCHAR(256));

DROP FUNCTION IF EXISTS public.get_genre_movies(genre_name_v VARCHAR(256));

DROP FUNCTION IF EXISTS public.get_genre_series(genre_name_v VARCHAR(256));