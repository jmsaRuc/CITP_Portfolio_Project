DROP TRIGGER IF EXISTS after_insert_episode ON episode;
DROP TRIGGER IF EXISTS after_insert_series ON series;

DROP FUNCTION IF EXISTS create_episode_type_after_insert;
DROP FUNCTION IF EXISTS create_series_type_after_insert

DROP FUNCTION IF EXISTS create_movie_type_after_insert

DROP TRIGGER IF EXISTS after_insert_movie ON movie;
DROP FUNCTION IF EXISTS create_type_after_insert;

DROP TRIGGER IF EXISTS after_delete_episode ON episode;
DROP TRIGGER IF EXISTS after_delete_series ON series;

DROP FUNCTION IF EXISTS delete_episode_type_after_delete;
DROP FUNCTION IF EXISTS delete_series_type_after_delete;

DROP TRIGGER IF EXISTS after_delete_movie ON movie;
DROP FUNCTION IF EXISTS delete_movie_type_after_delete;

DROP FUNCTION IF EXISTS create_movie_type_after_insert;

DROP FUNCTION IF EXISTS create_series_type_after_insert;