---------------------------type insert triggers-----------------------------


CREATE OR REPLACE FUNCTION create_movie_type_after_insert()
    RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO type (type_id, title_type)
        VALUES (NEW.movie_id, 'movie');
        RETURN NEW;
    END; 
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION create_series_type_after_insert()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO type (type_id, title_type)
    VALUES (NEW.series_id, 'series');
    RETURN NEW;
END; 
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION create_episode_type_after_insert()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO type (type_id, title_type)
    VALUES (NEW.episode_id, 'episode');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_insert_movie
    AFTER INSERT
    ON movie
    FOR EACH ROW
    EXECUTE FUNCTION create_movie_type_after_insert();

CREATE OR REPLACE TRIGGER after_insert_series
    AFTER INSERT
    ON series
    FOR EACH ROW
    EXECUTE FUNCTION create_series_type_after_insert();

CREATE OR REPLACE TRIGGER after_insert_episode
    AFTER INSERT
    ON episode
    FOR EACH ROW
    EXECUTE FUNCTION create_episode_type_after_insert();

---------------------------type delete triggers-----------------------------

CREATE OR REPLACE FUNCTION delete_movie_type_after_delete()
    RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM type
    WHERE type_id = OLD.movie_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION delete_series_type_after_delete()
    RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM type
    WHERE type_id = OLD.series_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION delete_episode_type_after_delete()
    RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM type
    WHERE type_id = OLD.episode_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_delete_movie
    AFTER DELETE
    ON movie
    FOR EACH ROW
    EXECUTE FUNCTION delete_movie_type_after_delete();

CREATE OR REPLACE TRIGGER after_delete_series
    AFTER DELETE
    ON series
    FOR EACH ROW
    EXECUTE FUNCTION delete_series_type_after_delete();

CREATE OR REPLACE TRIGGER after_delete_episode
    AFTER DELETE
    ON episode
    FOR EACH ROW
    EXECUTE FUNCTION delete_episode_type_after_delete();