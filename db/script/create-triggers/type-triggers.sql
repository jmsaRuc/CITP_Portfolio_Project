---------------------------type insert triggers-----------------------------


CREATE OR REPLACE FUNCTION public.create_movie_type_after_insert()
    RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO public.type ("type_id", title_type)
        VALUES (NEW.movie_id, 'movie');
        RETURN NEW;
    END; 
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION public.create_series_type_after_insert()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.type ("type_id", title_type)
    VALUES (NEW.series_id, 'series');
    RETURN NEW;
END; 
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION public.create_episode_type_after_insert()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.type ("type_id", title_type)
    VALUES (NEW.episode_id, 'episode');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_insert_movie
    AFTER INSERT
    ON public.movie
    FOR EACH ROW
    EXECUTE FUNCTION public.create_movie_type_after_insert();

CREATE OR REPLACE TRIGGER after_insert_series
    AFTER INSERT
    ON public.series
    FOR EACH ROW
    EXECUTE FUNCTION public.create_series_type_after_insert();

CREATE OR REPLACE TRIGGER after_insert_episode
    AFTER INSERT
    ON public.episode
    FOR EACH ROW
    EXECUTE FUNCTION public.create_episode_type_after_insert();

---------------------------type delete triggers-----------------------------

CREATE OR REPLACE FUNCTION public.delete_movie_type_after_delete()
    RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public.type
    WHERE "type_id" = OLD.movie_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION public.delete_series_type_after_delete()
    RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public.type
    WHERE "type_id" = OLD.series_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION public.delete_episode_type_after_delete()
    RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public.type
    WHERE "type_id" = OLD.episode_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_delete_movie
    AFTER DELETE
    ON public.movie
    FOR EACH ROW
    EXECUTE FUNCTION public.delete_movie_type_after_delete();

CREATE OR REPLACE TRIGGER after_delete_series
    AFTER DELETE
    ON public.series
    FOR EACH ROW
    EXECUTE FUNCTION public.delete_series_type_after_delete();

CREATE OR REPLACE TRIGGER after_delete_episode
    AFTER DELETE
    ON public.episode
    FOR EACH ROW
    EXECUTE FUNCTION public.delete_episode_type_after_delete();

---------------------------type update triggers-----------------------------
