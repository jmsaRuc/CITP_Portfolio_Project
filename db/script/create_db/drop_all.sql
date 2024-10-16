-- Active: 1727253378954@@127.0.0.1@5532@portf_1

SET search_path TO public, pgtap;

DROP TABLE IF EXISTS public.user_movie_interaction CASCADE;
DROP TABLE IF EXISTS public.user_series_interaction CASCADE;
DROP TABLE IF EXISTS public.user_episode_interaction CASCADE;
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

DROP EXTENSION IF EXISTS pgtap
    SCHEMA pgtap
    VERSION "1.3.3"
    CASCADE; 

DROP SCHEMA pgtap CASCADE;