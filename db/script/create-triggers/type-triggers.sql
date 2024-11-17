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

-----------------------------popularity insert triggers-----------------------------

CREATE OR REPLACE FUNCTION public.update_popularity_after_insert()
    RETURNS TRIGGER AS $$
DECLARE
    what_type VARCHAR;
    pop_count bigint;
BEGIN
    SELECT title_type INTO what_type
    FROM public.type
    WHERE "type_id" = NEW."type_id";

    SELECT count(*) INTO pop_count 
    FROM public.recent_view
    WHERE "type_id" = NEW."type_id"
    GROUP BY "type_id";

    
    IF what_type = 'movie' 
    THEN
        UPDATE public.movie
        SET popularity = pop_count
        WHERE "movie_id" = NEW."type_id";
        RETURN NEW;
    END IF;  

    IF what_type = 'series' 
    THEN 
        UPDATE public.series
        SET popularity = pop_count
        WHERE "series_id" = NEW."type_id";
        RETURN NEW;
    END IF;   

    IF what_type = 'episode' 
    THEN
        UPDATE public.episode
        SET popularity = pop_count
        WHERE "episode_id" = NEW."type_id";
        RETURN NEW;
    END IF;

    IF what_type = 'person' 
    THEN
        UPDATE public.person
        SET popularity = pop_count
        WHERE "person_id" = NEW."type_id";
        RETURN NEW;
    END IF;   
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_insert_recent_view
    AFTER INSERT
    ON public.recent_view
    FOR EACH ROW
    EXECUTE FUNCTION public.update_popularity_after_insert();

-----------------------------popularity delet triggers-----------------------------

CREATE OR REPLACE FUNCTION public.update_popularity_after_delete()
    RETURNS TRIGGER AS $$
DECLARE
    what_type VARCHAR;
    pop_count bigint;
BEGIN
    SELECT title_type INTO what_type
    FROM public.type
    WHERE "type_id" = OLD."type_id";

    SELECT count(*) INTO pop_count 
    FROM public.recent_view
    WHERE "type_id" = OLD."type_id"
    GROUP BY "type_id";

    IF pop_count IS NULL
    THEN
        pop_count := 0;
    END IF;
    
    IF what_type = 'movie' 
    THEN
        UPDATE public.movie
        SET popularity = pop_count
        WHERE "movie_id" = OLD."type_id";
        RETURN OLD;
    END IF;  

    IF what_type = 'series' 
    THEN 
        UPDATE public.series
        SET popularity = pop_count
        WHERE "series_id" = OLD."type_id";
        RETURN OLD;
    END IF;   

    IF what_type = 'episode' 
    THEN
        UPDATE public.episode
        SET popularity = pop_count
        WHERE "episode_id" = OLD."type_id";
        RETURN OLD;
    END IF;

    IF what_type = 'person' 
    THEN
        UPDATE public.person
        SET popularity = pop_count
        WHERE "person_id" = OLD."type_id";
        RETURN OLD;
    END IF;   
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_delete_recent_view
    AFTER DELETE
    ON public.recent_view
    FOR EACH ROW
    EXECUTE FUNCTION public.update_popularity_after_delete();

--------------------------------------------------- rating insert triggers ---------------------------------------------------

-- movie

CREATE OR REPLACE FUNCTION public.update_movie_average_rating_after_insert()
    RETURNS TRIGGER AS $$
DECLARE
    rated_average numeric(5,1);
BEGIN
    SELECT avg(rating) INTO rated_average
    FROM public.user_movie_rating
    WHERE movie_id = NEW."movie_id";

    UPDATE public.movie
    SET average_rating = rated_average
    WHERE "movie_id" = NEW."movie_id";
    RETURN NEW;

END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_insert_movie_rating
    AFTER INSERT
    ON public.user_movie_rating
    FOR EACH ROW
    EXECUTE FUNCTION public.update_movie_average_rating_after_insert();

-- episode

CREATE OR REPLACE FUNCTION public.update_episode_average_rating_after_insert()
    RETURNS TRIGGER AS $$
DECLARE
    rated_average numeric(5,1);
BEGIN
    SELECT avg(rating) INTO rated_average
    FROM public.user_episode_rating
    WHERE episode_id = NEW."episode_id";

    UPDATE public.episode
    SET average_rating = rated_average
    WHERE "episode_id" = NEW."episode_id";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_insert_episode_rating
    AFTER INSERT
    ON public.user_episode_rating
    FOR EACH ROW
    EXECUTE FUNCTION public.update_episode_average_rating_after_insert();

-- series

CREATE OR REPLACE FUNCTION public.update_series_average_rating_after_insert()
    RETURNS TRIGGER AS $$
DECLARE
    rated_average numeric(5,1);
BEGIN
    SELECT avg(rating) INTO rated_average
    FROM public.user_series_rating
    WHERE series_id = NEW."series_id";

    UPDATE public.series
    SET average_rating = rated_average
    WHERE "series_id" = NEW."series_id";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_insert_series_rating
    AFTER INSERT
    ON public.user_series_rating
    FOR EACH ROW
    EXECUTE FUNCTION public.update_series_average_rating_after_insert();



--------------------------------------------------- rating insert triggers on delet ---------------------------------------------------    

-- movie
CREATE OR REPLACE FUNCTION public.update_movie_average_rating_after_delete()
    RETURNS TRIGGER AS $$
DECLARE
    rated_average numeric(5,1);
BEGIN
    SELECT avg(rating) INTO rated_average
    FROM public.user_movie_rating
    WHERE movie_id = OLD."movie_id";
    
    UPDATE public.movie
    SET average_rating = rated_average
    WHERE "movie_id" = OLD."movie_id";
    RETURN OLD;

END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_delet_movie_rating
    AFTER DELETE
    ON public.user_movie_rating
    FOR EACH ROW
    EXECUTE FUNCTION public.update_movie_average_rating_after_delete();
-- episode

CREATE OR REPLACE FUNCTION public.update_episode_average_rating_after_delete()
    RETURNS TRIGGER AS $$
DECLARE
    rated_average numeric(5,1);
BEGIN
    SELECT avg(rating) INTO rated_average
    FROM public.user_episode_rating
    WHERE episode_id = OLD."episode_id";

    UPDATE public.episode
    SET average_rating = rated_average
    WHERE "episode_id" = OLD."episode_id";
    RETURN OLD;

END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_delet_episode_rating
    AFTER DELETE
    ON public.user_episode_rating
    FOR EACH ROW
    EXECUTE FUNCTION public.update_episode_average_rating_after_delete();

-- series

CREATE OR REPLACE FUNCTION public.update_series_average_rating_after_delete()
    RETURNS TRIGGER AS $$
DECLARE
    rated_average numeric(5,1);
BEGIN
    SELECT avg(rating) INTO rated_average
    FROM public.user_series_rating
    WHERE series_id = OLD."series_id";

    UPDATE public.series
    SET average_rating = rated_average
    WHERE "series_id" = OLD."series_id";
    RETURN OLD;

END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_delet_series_rating
    AFTER DELETE
    ON public.user_series_rating
    FOR EACH ROW
    EXECUTE FUNCTION public.update_series_average_rating_after_delete();