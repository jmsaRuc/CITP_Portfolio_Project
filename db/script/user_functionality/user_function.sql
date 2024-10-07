-- Active: 1727253378954@@127.0.0.1@5532@portf_1

-- Function to create a user. d1
CREATE OR REPLACE FUNCTION PUBLIC.create_user(
    new_username VARCHAR(50),
    new_password bytea,
    new_email VARCHAR(256)
    )
RETURNS BOOLEAN AS $$
DECLARE
    user_exists BOOLEAN;
    new_user_id VARCHAR(10);
BEGIN
    SELECT
        EXISTS(
            SELECT username
            FROM "user"
            WHERE
                username = new_username
        )
    INTO user_exists;
    IF user_exists THEN
        RETURN FALSE;
    ELSE 
        new_user_id := 'ur' || LPAD((SELECT COUNT(*)+1 FROM "user")::text, 8, '0');
        INSERT INTO "user" (user_id, username, password, email, created_at)
        VALUES (new_user_id, 
         new_username, 
         new_password,
            new_email, 
         current_date);
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS create_user (
    username VARCHAR(50),
    password bytea,
    email VARCHAR(256)
);
-- Function to delete a user.
CREATE OR REPLACE FUNCTION delete_user(
    v_username VARCHAR(50)
)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM "user"
    WHERE
        username = v_username;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function to bookmark a name.
CREATE OR REPLACE FUNCTION bookmark_name(
    username VARCHAR(50),
    name_id VARCHAR(50)
)
RETURNS BOOLEAN AS $$
DECLARE
    user_exists BOOLEAN;
BEGIN
    SELECT
        EXISTS(
            SELECT
                1
            FROM users
            WHERE
                username = bookmark_name.username
        )
    INTO user_exists;

    IF user_exists THEN
        INSERT INTO user_name (username, name_id)
        VALUES (bookmark_name.username, bookmark_name.name_id);
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to watchlist movie.
CREATE OR REPLACE FUNCTION new_watchlist_movie(
    who_user_id VARCHAR(50),
    watchlisted_movie_id VARCHAR(50)
)
RETURNS BOOLEAN AS $$
DECLARE
    movie_is_watchlisted BOOLEAN;
BEGIN
    SELECT
        EXISTS(
            SELECT
                1
            FROM user_movie_interaction
            WHERE user_id = who_user_id
                AND movie_id = watchlisted_movie_id
                AND watchlist > 0
        )
    INTO movie_is_watchlisted;

    IF movie_is_watchlisted THEN
        RETURN FALSE;
    ELSE
        INSERT INTO user_movie_interaction (user_id, movie_id, watchlist)
        VALUES (who_user_id, watchlisted_movie_id, (SELECT count(*) FROM user_movie_interaction WHERE user_id = who_user_id AND watchlist > 0) + 1);
        RETURN TRUE;
    END IF;
END;

$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delet_watchlist_movie
    (who_user_id VARCHAR(50),
    watchlisted_movie_id VARCHAR(50))
RETURNS BOOLEAN AS $$
DECLARE
    movie_is_watchlisted BOOLEAN;
BEGIN
    SELECT
        EXISTS(
            SELECT
                1
            FROM user_movie_interaction
            WHERE user_id = who_user_id
                AND movie_id = watchlisted_movie_id
                AND watchlist > 0
        )
    INTO movie_is_watchlisted;

    IF movie_is_watchlisted THEN
        DELETE FROM user_movie_interaction
        WHERE user_id = who_user_id
            AND movie_id = watchlisted_movie_id;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

--- Function to watchlist series.
CREATE OR REPLACE FUNCTION new_watchlist_series(
    who_user_id VARCHAR(50),
    watchlisted_series_id VARCHAR(50)
)
RETURNS BOOLEAN AS $$
DECLARE
    series_is_watchlisted BOOLEAN;
BEGIN
    SELECT
        EXISTS(
            SELECT
                1
            FROM user_series_interaction
            WHERE user_id = who_user_id
                AND series_id = watchlisted_series_id
                AND watchlist > 0
        )
    INTO series_is_watchlisted;

    IF series_is_watchlisted THEN
        RETURN FALSE;
    ELSE
        INSERT INTO user_series_interaction (user_id, series_id, watchlist)
        VALUES (who_user_id, watchlisted_series_id, (SELECT count(*) FROM user_series_interaction WHERE user_id = who_user_id AND watchlist > 0) + 1);
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delet_watchlist_series
    (who_user_id VARCHAR(50),
    watchlisted_series_id VARCHAR(50))
RETURNS BOOLEAN AS $$
DECLARE
    series_is_watchlisted BOOLEAN;
BEGIN
    SELECT
        EXISTS(
            SELECT
                1
            FROM user_series_interaction
            WHERE user_id = who_user_id
                AND series_id = watchlisted_series_id
                AND watchlist > 0
        )
    INTO series_is_watchlisted;

    IF series_is_watchlisted THEN
        DELETE FROM user_series_interaction
        WHERE user_id = who_user_id
            AND series_id = watchlisted_series_id;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

---- Function to watchlist episode.
CREATE OR REPLACE FUNCTION new_watchlist_episode(
    who_user_id VARCHAR(50),
    watchlisted_episode_id VARCHAR(50)
)
RETURNS BOOLEAN AS $$
DECLARE
    episode_is_watchlisted BOOLEAN;
BEGIN
    SELECT
        EXISTS(
            SELECT
                1
            FROM user_episode_interaction
            WHERE user_id = who_user_id
                AND episode_id = watchlisted_episode_id
                AND watchlist > 0
        )
    INTO episode_is_watchlisted;

    IF episode_is_watchlisted THEN
        RETURN FALSE;
    ELSE
        INSERT INTO user_episode_interaction (user_id, episode_id, watchlist)
        VALUES (who_user_id, watchlisted_episode_id, (SELECT count(*) FROM user_episode_interaction WHERE user_id = who_user_id AND watchlist > 0) + 1);
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delet_watchlist_episode
    (who_user_id VARCHAR(50),
    watchlisted_episode_id VARCHAR(50))
RETURNS BOOLEAN AS $$
DECLARE
    episode_is_watchlisted BOOLEAN;
BEGIN
    SELECT
        EXISTS(
            SELECT
                1
            FROM user_episode_interaction
            WHERE user_id = who_user_id
                AND episode_id = watchlisted_episode_id
                AND watchlist > 0
        )
    INTO episode_is_watchlisted;

    IF episode_is_watchlisted THEN
        DELETE FROM user_episode_interaction
        WHERE user_id = who_user_id
            AND episode_id = watchlisted_episode_id;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

----- D2 simple search
CREATE OR REPLACE FUNCTION "public"."string_search"(S text) 
  RETURNS TABLE(id varchar, title varchar) AS $$ 
BEGIN 
    RETURN QUERY 
    SELECT  
        movie_id AS id,  
        movie.title  
    FROM  
        movie 
    WHERE 
        LOWER(movie.title) LIKE LOWER('%' || S || '%') or 
        LOWER(movie.plot) LIKE LOWER('%' || S || '%'); 
END; 
$$ LANGUAGE plpgsql;

--- D6
 CREATE OR REPLACE VIEW actorcoplayers AS
 SELECT is_in_movie.movie_id,
    person.person_id,
    person.name, 
    movie.title,
    is_in_movie.role 
   FROM is_in_movie 
     JOIN person ON is_in_movie.person_id::text = person.person_id::text 
     JOIN movie ON is_in_movie.movie_id::text = movie.movie_id::text 
  WHERE lower(is_in_movie.role::text) = ANY (ARRAY['actor'::text, 'actress'::text]);

CREATE OR REPLACE FUNCTION "public"."find_co_players"(actorname text) 
  RETURNS TABLE("actor" varchar, "co_actor" varchar, "frequency" int8) AS $$ 
  BEGIN 
   RETURN QUERY 
    WITH actor_movies AS ( 
        SELECT actorcoplayers.movie_id 
        FROM actorcoplayers
        WHERE actorcoplayers.name = actorname), 
         count_actor AS ( 
         SELECT actorcoplayers.person_id AS actor, 
        actorcoplayers.name AS co_actor, 
        COUNT(*) AS frequency 
        FROM actorcoplayers 
        JOIN actor_movies on actorcoplayers.movie_id = actor_movies.movie_id 
        WHERE actorcoplayers.name != actorname 
        GROUP BY actorcoplayers.person_id, actorcoplayers.name 
         ) 
        SELECT  
        count_actor.actor, 
        count_actor.co_actor, 
        count_actor.frequency 
    FROM  
        count_actor 
           ORDER BY  
        frequency DESC; 
        END; 
$$ 
LANGUAGE plpgsql VOLATILE; 
