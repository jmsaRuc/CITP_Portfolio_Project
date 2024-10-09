-- Active: 1727257766643@@127.0.0.1@5532@OMGDB_db

-- Creating functions to manage users and for bookmarking names and titles. 

-- Function to create a user.
CREATE OR REPLACE FUNCTION create_user(
    username VARCHAR(50),
    password VARCHAR(50)
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
                username = create_user.username
        )
    INTO user_exists;

    IF user_exists THEN
        RETURN FALSE;
    ELSE
        INSERT INTO users (username, password)
        VALUES (create_user.username, create_user.password);
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to delete a user.
CREATE OR REPLACE FUNCTION delete_user(
    username VARCHAR(50)
)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM users
    WHERE
        username = delete_user.username;
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
CREATE OR REPLACE FUNCTION bookmark_title(
    username VARCHAR(50),
    title_id VARCHAR(50)
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
                username = bookmark_title.username
        )
    INTO user_exists;

    IF user_exists THEN
        INSERT INTO user_title (username, title_id)
        VALUES (bookmark_title.username, bookmark_title.title_id);
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to unbookmark a name.
CREATE OR REPLACE FUNCTION unbookmark_name(
    username VARCHAR(50),
    name_id VARCHAR(50)
)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM user_name
    WHERE
        username = unbookmark_name.username
        AND name_id = unbookmark_name.name_id;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function to unbookmark a title.
CREATE OR REPLACE FUNCTION unbookmark_title(
    username VARCHAR(50),
    title_id VARCHAR(50)
)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM user_title
    WHERE
        username = unbookmark_title.username
        AND title_id = unbookmark_title.title_id;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Funtion to retrieve all bookmarked names.
CREATE OR REPLACE FUNCTION get_bookmarked_names(
    username VARCHAR(50)
)
RETURNS TABLE (
    name_id VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        name_id
    FROM user_name
    WHERE
        username = get_bookmarked_names.username;
END;
$$ LANGUAGE plpgsql;

-- Function to retrieve all bookmarked titles.
CREATE OR REPLACE FUNCTION get_bookmarked_titles(
    username VARCHAR(50)
)
RETURNS TABLE (
    title_id VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        title_id
    FROM user_title
    WHERE
        username = get_bookmarked_titles.username;
END;
$$ LANGUAGE plpgsql;