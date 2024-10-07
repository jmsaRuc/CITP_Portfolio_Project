-- Active: 1727253378954@@127.0.0.1@5532@portf_1

-- Function to create a user.
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

DROP FUNCTION IF EXISTS create_user(
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

-- Function to bookmark a title.
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
CREATE OR REPLACE FUNCTION update_watchlisted_movie(
    who_user_id VARCHAR(50),
    watchlisted_movie_id VARCHAR(50)
)
RETURNS VARCHAR(10) AS $$
DECLARE
    movie_is_watchlisted BOOLEAN;
BEGIN
    SELECT new_watchlist_movie(who_user_id, watchlisted_movie_id )
    INTO movie_is_watchlisted;

    IF movie_is_watchlisted THEN
        RETURN 'watchlisted added';
    ELSE
        UPDATE user_movie_interaction
        SET who_user_id, watchlisted_movie_id, (SELECT count(*) FROM user_movie_interaction WHERE user_id = who_user_id AND watchlist > 0) + 1);
        RETURN 'watchlisted updated';
    END IF;
END;
$$ LANGUAGE plpgsql;
