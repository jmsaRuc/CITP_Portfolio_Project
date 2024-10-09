
-- Structured string search with 4 string parameters, return titles that match these on title, the plot and the characters and the person names. Make the function flexible enough for it to not care about case of letters and argument values. Return the tconst and primary_title of the titles that match the search criteria. If no titles match the search criteria, return an empty set. If any of the parameters are NULL

CREATE OR REPLACE FUNCTION search_titles(
    title VARCHAR(50),
    plot VARCHAR(50),
    characters VARCHAR(50),
    person_names VARCHAR(50)
)
RETURNS TABLE (
    tconst VARCHAR(50),
    primary_title VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        tconst,
        primary_title
    FROM title
    WHERE
        LOWER(primary_title) LIKE '%' || LOWER(search_titles.title) || '%'
        AND LOWER(plot) LIKE '%' || LOWER(search_titles.plot) || '%'
        AND LOWER(characters) LIKE '%' || LOWER(search_titles.characters) || '%'
        AND LOWER(person_names) LIKE '%' || LOWER(search_titles.person_names) || '%';
END;
$$ LANGUAGE plpgsql;

-- D.5 Function to search for finding actors using 4 string parameters.

CREATE OR REPLACE FUNCTION search_actors(
    name VARCHAR(50),
    characters VARCHAR(50),
    titles VARCHAR(50)
)
RETURNS TABLE (
    nconst VARCHAR(50),
    primary_name VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        nconst,
        primary_name
    FROM name
    WHERE
        LOWER(primary_name) LIKE '%' || LOWER(search_actors.name) || '%'
        AND LOWER(characters) LIKE '%' || LOWER(search_actors.characters) || '%'
        AND LOWER(titles) LIKE '%' || LOWER(search_actors.titles) || '%';
END;
$$ LANGUAGE plpgsql;