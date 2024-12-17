---------------------------type insert triggers-----------------------------


CREATE OR REPLACE FUNCTION public.create_movie_type_after_insert()
    RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO public."type" ("type_id", title_type)
        VALUES (NEW.movie_id, 'movie');
        RETURN NEW;
    END; 
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION public.create_series_type_after_insert()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public."type" ("type_id", title_type)
    VALUES (NEW.series_id, 'series');
    RETURN NEW;
END; 
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION public.create_episode_type_after_insert()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public."type" ("type_id", title_type)
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
    DELETE FROM public."type"
    WHERE "type_id" = OLD.movie_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION public.delete_series_type_after_delete()
    RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public."type"
    WHERE "type_id" = OLD.series_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION public.delete_episode_type_after_delete()
    RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public."type"
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
    FROM public."type"
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

        WITH filte as (
            SELECT person_id, cast_order
            FROM public.is_in_movie
            WHERE movie_id = NEW."type_id"
        )
        UPDATE public.person as d
        SET popularity = ((1/cast_order::NUMERIC)*pop_count)::BIGINT
        FROM filte
        WHERE d.person_id = filte.person_id;

        RETURN NEW;
    END IF;  

    IF what_type = 'series' 
    THEN 
        UPDATE public.series
        SET popularity = pop_count
        WHERE "series_id" = NEW."type_id";

        WITH filte as (
            SELECT person_id, cast_order
            FROM public.is_in_series
            WHERE series_id = NEW."type_id"
        )
        UPDATE public.person as d
        SET popularity = ((1/cast_order::NUMERIC)*pop_count)::BIGINT
        FROM filte
        WHERE d.person_id = filte.person_id;

        RETURN NEW;
    END IF;   

    IF what_type = 'episode' 
    THEN
        UPDATE public.episode
        SET popularity = pop_count
        WHERE "episode_id" = NEW."type_id";

        
        WITH filte as (
            SELECT person_id, cast_order
            FROM public.is_in_episode
            WHERE episode_id = NEW."type_id"
        )
        UPDATE public.person as d
        SET popularity = ((1/cast_order::NUMERIC)*pop_count)::BIGINT
        FROM filte
        WHERE d.person_id = filte.person_id;

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

-----------------------------popularity update triggers used for search-----------------------------

CREATE OR REPLACE FUNCTION public.update_search_popularity_after_movie_update()
    RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.movie_search
    SET popularity = NEW.popularity
    WHERE "movie_id" = NEW."movie_id";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION public.update_search_popularity_after_series_update()
    RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.series_search
    SET popularity = NEW.popularity
    WHERE "series_id" = NEW."series_id";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION public.update_search_popularity_after_episode_update()
    RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.episode_search
    SET popularity = NEW.popularity
    WHERE "episode_id" = NEW."episode_id";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION public.update_search_popularity_after_person_update()
    RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.person_search
    SET popularity = NEW.popularity
    WHERE "person_id" = NEW."person_id";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_update_movie_search_popularity
    AFTER UPDATE
    ON public.movie
    FOR EACH ROW
    EXECUTE FUNCTION public.update_search_popularity_after_movie_update();

CREATE OR REPLACE TRIGGER after_update_series_search_popularity
    AFTER UPDATE
    ON public.series
    FOR EACH ROW
    EXECUTE FUNCTION public.update_search_popularity_after_series_update();

CREATE OR REPLACE TRIGGER after_update_episode_search_popularity
    AFTER UPDATE
    ON public.episode
    FOR EACH ROW
    EXECUTE FUNCTION public.update_search_popularity_after_episode_update();


CREATE OR REPLACE TRIGGER after_update_person_search_popularity
    AFTER UPDATE
    ON public.person
    FOR EACH ROW
    EXECUTE FUNCTION public.update_search_popularity_after_person_update();    


-----------------------------popularity delet triggers-----------------------------

CREATE OR REPLACE FUNCTION public.update_popularity_after_delete()
    RETURNS TRIGGER AS $$
DECLARE
    what_type VARCHAR;
    pop_count bigint;
BEGIN
    SELECT title_type INTO what_type
    FROM public."type"
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

        WITH filte as (
            SELECT person_id, cast_order
            FROM public.is_in_movie
            WHERE movie_id = OLD."type_id"
        )
        UPDATE public.person as d
        SET popularity = ((1/cast_order::NUMERIC)*pop_count)::BIGINT
        FROM filte
        WHERE d.person_id = filte.person_id;

        RETURN OLD;
    END IF;  

    IF what_type = 'series' 
    THEN 
        UPDATE public.series
        SET popularity = pop_count
        WHERE "series_id" = OLD."type_id";

        WITH filte as (
            SELECT person_id, cast_order
            FROM public.is_in_series
            WHERE series_id = OLD."type_id"
        )
        UPDATE public.person as d
        SET popularity = ((1/cast_order::NUMERIC)*pop_count)::BIGINT
        FROM filte
        WHERE d.person_id = filte.person_id;
        
        RETURN OLD;
    END IF;   

    IF what_type = 'episode' 
    THEN
        UPDATE public.episode
        SET popularity = pop_count
        WHERE "episode_id" = OLD."type_id";

        WITH filte as (
            SELECT person_id, cast_order
            FROM public.is_in_episode
            WHERE episode_id = OLD."type_id"
        )
        UPDATE public.person as d
        SET popularity = ((1/cast_order::NUMERIC)*pop_count)::BIGINT
        FROM filte
        WHERE d.person_id = filte.person_id;

        RETURN OLD;
    END IF;

    IF what_type = 'person' 
    THEN
        UPDATE public.person
        SET popularity = pop_count
        WHERE "person_id" = OLD."type_id";
        RETURN OLD;
    END IF;
    RETURN OLD;   
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_delete_recent_view
    AFTER DELETE
    ON public.recent_view
    FOR EACH ROW
    EXECUTE FUNCTION public.update_popularity_after_delete();

--------------------------------------------------- refresh materialized view trigger top this week ---------------------------------------------------

CREATE OR REPLACE FUNCTION public.refresh_if_new_day()
    RETURNS TRIGGER AS $$
BEGIN
    IF (
        SELECT count(*)
        FROM public.top_this_week) <= 0
    THEN 
        REFRESH MATERIALIZED VIEW CONCURRENTLY public.top_this_week;
        RETURN NULL;
    ELSEIF (
        SELECT max(pop_created_at)
        FROM public.top_this_week) <= (now() - INTERVAL '1 day')
    THEN 
        REFRESH MATERIALIZED VIEW CONCURRENTLY public.top_this_week;
        RETURN NULL;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_insert_refresh_top_this_week
    AFTER INSERT
    ON public.recent_view
    FOR EACH ROW
    EXECUTE FUNCTION public.refresh_if_new_day();

--------------------------------------------------- rating insert or update triggers ---------------------------------------------------

-- movie

CREATE OR REPLACE FUNCTION public.update_movie_average_rating_after_insert()
    RETURNS TRIGGER AS $$
DECLARE
    rated_average numeric(5,1);
BEGIN
    SELECT avg(rating) INTO rated_average
    FROM public.user_movie_rating
    WHERE movie_id = NEW."movie_id";

    IF rated_average IS NULL
    THEN
        rated_average := 0;
    END IF;

    UPDATE public.movie
    SET average_rating = rated_average
    WHERE "movie_id" = NEW."movie_id";
    RETURN NEW;

END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_insert_movie_rating
    AFTER INSERT OR UPDATE
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

    IF rated_average IS NULL
    THEN
        rated_average := 0;
    END IF;

    UPDATE public.episode
    SET average_rating = rated_average
    WHERE "episode_id" = NEW."episode_id";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_insert_episode_rating
    AFTER INSERT OR UPDATE
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

    IF rated_average IS NULL
    THEN
        rated_average := 0;
    END IF;

    UPDATE public.series
    SET average_rating = rated_average
    WHERE "series_id" = NEW."series_id";
    RETURN NEW;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE TRIGGER after_insert_series_rating
    AFTER INSERT OR UPDATE 
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

    IF rated_average IS NULL
    THEN
        rated_average := 0;
    END IF;
    
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

    IF rated_average IS NULL
    THEN
        rated_average := 0;
    END IF;

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

    IF rated_average IS NULL
    THEN
        rated_average := 0;
    END IF;

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