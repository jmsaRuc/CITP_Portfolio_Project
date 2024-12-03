-- Active: 1727253378954@@127.0.0.1@5532@portf_1

SET search_path TO public, pgtap;

DROP TABLE IF EXISTS public.user_movie_watchlist CASCADE;
DROP TABLE IF EXISTS public.user_series_watchlist CASCADE;
DROP TABLE IF EXISTS public.user_episode_watchlist CASCADE;

DROP TABLE IF EXISTS public.user_movie_rating CASCADE;
DROP TABLE IF EXISTS public.user_series_rating CASCADE;
DROP TABLE IF EXISTS public.user_episode_rating CASCADE;

DROP TABLE IF EXISTS public.movie_language CASCADE;
DROP TABLE IF EXISTS public.series_language CASCADE;
DROP TABLE IF EXISTS public.episode_language CASCADE;
DROP TABLE IF EXISTS public.is_in_movie CASCADE;
DROP TABLE IF EXISTS public.is_in_series CASCADE;
DROP TABLE IF EXISTS public.is_in_episode CASCADE;
DROP TABLE IF EXISTS public.movie_genre CASCADE;
DROP TABLE IF EXISTS public.series_genre CASCADE;
DROP TABLE IF EXISTS public.episode_genre CASCADE;
DROP TABLE IF EXISTS public.movie_keywords CASCADE;
DROP TABLE IF EXISTS public.series_keywords CASCADE;
DROP TABLE IF EXISTS public.episode_keywords CASCADE;
DROP TABLE IF EXISTS public.person_keywords CASCADE;
DROP TABLE IF EXISTS public.person CASCADE;
DROP TABLE IF EXISTS public.episode CASCADE;
DROP TABLE IF EXISTS public.episode_series CASCADE;
DROP TABLE IF EXISTS public.series CASCADE;
DROP TABLE IF EXISTS public.user CASCADE;
DROP TABLE IF EXISTS public.recent_view CASCADE;
DROP TABLE IF EXISTS public.type CASCADE;
DROP TABLE IF EXISTS public.movie CASCADE;

DROP SEQUENCE IF EXISTS public.title_seq CASCADE;
DROP SEQUENCE IF EXISTS public.user_seq CASCADE;
DROP SEQUENCE IF EXISTS public.person_seq CASCADE;

DROP SEQUENCE IF EXISTS public.watchlist_seq CASCADE;

DROP EXTENSION IF EXISTS pgtap
    SCHEMA pgtap
    VERSION "1.3.3"
    CASCADE; 

DROP SCHEMA pgtap CASCADE;

DROP TABLE IF EXISTS public.title_basics;

DROP TABLE IF EXISTS public.title_episode;

DROP TABLE IF EXISTS public.title_principals;

DROP TABLE IF EXISTS public.title_ratings;

DROP TABLE IF EXISTS public.omdb_data;

DROP TABLE IF EXISTS public.name_basics;

DROP TABLE IF EXISTS public.wi;

DROP TABLE IF EXISTS public.title_akas;

DROP TABLE IF EXISTS public.title_crew;