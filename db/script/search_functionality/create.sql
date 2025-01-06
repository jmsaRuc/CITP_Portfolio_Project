--------------------------------------------------------------
--misc
-------------------------------------------------------------

SET search_path TO public, pgtap, fuzzy;

------------------------series

------------------------episode

----------------------all

-----------------------------------------------------------------------
--general functions
-----------------------------------------------------------------------
----fuzzy rank
CREATE OR REPLACE FUNCTION public.get_fuzzy_rank(title text, search_query text)
   RETURNS NUMERIC AS $$
      select fuzzy.similarity(title, search_query) * (title <-> websearch_to_tsquery('english', search_query)::text);
$$ LANGUAGE SQL;

-----rank boost w system  0.5 A, 0.05 B, 0.005 C, 0.0005 D

-----rank_boost on rating with popularity thresh hold rank B
CREATE OR REPLACE FUNCTION public.rank_boost_rating(rating numeric, popularity BIGINT, voteThreshold BIGINT)
	returns numeric as $$
		select case when popularity < voteThreshold then 0 else (rating*0.05) end;
$$ language sql;

------rank_boost on release date on with popularity thresh hold rank b
CREATE OR REPLACE FUNCTION public.rank_boost_relese_date(relase_date date, now_date date, popularity BIGINT, voteThreshold BIGINT)
    returns numeric as $$
        select case when popularity < voteThreshold or relase_date is NULL then 0 else (1/(((now_date - relase_date)::numeric)/364))*0.05 end;
$$ language sql;

------------rank_boost on language rank english higher rank D
CREATE OR REPLACE FUNCTION public.rank_boost_language("language" text)
	returns NUMERIC as $$
    BEGIN
        if "language" is NULL or "language" = ''
        then
            return 0;
        ELSEIF position('English' in "language") > 0
            THEN
                RETURN 0.005;
            ELSE
                RETURN 0;
        END IF;
    END;
$$ language plpgsql;

------------rank_boost on rank on recent_viewed rank b
CREATE OR REPLACE FUNCTION public.rank_boost_recent_viewed(type_id_v VARCHAR, user_id_v VARCHAR)
    RETURNS NUMERIC AS $$
    BEGIN
        if EXISTS(
                SELECT
                    TRUE
                FROM recent_view
                WHERE
                "user_id" = user_id_v and "type_id" = type_id_v
        )
        THEN
            RETURN 0.05;
        ELSE
            RETURN 0;
        END IF;
    END;
$$ LANGUAGE plpgsql;

--------------------------------------------------------------------------------------------------------------
-----main
--------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- movie search function

CREATE OR REPLACE FUNCTION public.search_movie_quick(search_query TEXT, user_id_v VARCHAR)
    RETURNS TABLE(
        movie_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
BEGIN
    IF length(search_query) <= 2
    THEN
        RETURN;
    ELSEIF coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE            
        RETURN QUERY
            SELECT 
                movie_id, title, poster, average_rating, imdb_rating, popularity, ts_headline(
                    'english', q.title, websearch_to_tsquery('english', search_query), 
                    'MaxFragments=3,MaxWords=25,MinWords=2') highlight, q."rank"
            FROM (
                    SELECT ts_rank(
                            f."search", websearch_to_tsquery('english', search_query)
                        ) 
                        + public.rank_boost_rating (imdb_rating, popularity, 5) 
                        + public.rank_boost_language("language") 
                        + public.rank_boost_relese_date(release_date, CURRENT_DATE, popularity, 5)
                        + public.rank_boost_recent_viewed(movie_id, user_id_v)
                        + public.get_fuzzy_rank (title, search_query) 
                        RANK, *
                    FROM public.movie_search f, websearch_to_tsquery('english', search_query) AS tsq
                    WHERE
                        f."search" @@ to_tsquery('english', tsq::TEXT || ':*')
                ) q
            WHERE
                q.rank > 0.001
            ORDER BY RANK DESC NULLS LAST;
    END IF;        
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_movie_slow(search_query TEXT)
    RETURNS TABLE(
        movie_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
BEGIN
    IF length(search_query) <= 4
    THEN
        RETURN;
    ELSEIF
        coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE    
        RETURN QUERY
            WITH
                ranked_search AS (
                    SELECT ts_rank(
                            "search", websearch_to_tsquery('english', search_query)
                        ) 
                        + public.rank_boost_rating (imdb_rating, popularity, 5)
                        RANK, movie_id, title, poster, average_rating, imdb_rating, popularity
                    FROM public.movie_search
                    ORDER BY RANK DESC NULLS LAST
                    LIMIT 1000
                )
            SELECT movie_id, title, poster, average_rating, imdb_rating, popularity, 
                ts_headline(
                    'english', title, websearch_to_tsquery('english', search_query), 'MaxFragments=3,MaxWords=25,MinWords=2'
                ) Highlight, "rank"
            FROM ranked_search
            ORDER BY public.get_fuzzy_rank (
                    title,
                    to_tsquery(
                        'simple',
                        websearch_to_tsquery('english', search_query)::TEXT || ':*')::TEXT
                    ) DESC;

    END IF;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------seriesh spicific boost rank functions
CREATE OR REPLACE FUNCTION public.rank_boost_series_relese_date(start_year_v varchar(4), popularity BIGINT, voteThreshold BIGINT)
    returns numeric as $$
            DECLARE
                start_year date;
            BEGIN
                if start_year_v is NULL or start_year_v = ''
                then
                    return 0;
                ELSE
                    start_year := to_date(start_year_v, 'YYYY');
                    if popularity < voteThreshold or start_year is NULL
                    then
                        return 0;
                    ELSE
                        return (1/(((CURRENT_DATE - start_year)::numeric)/364))*0.005;
                    END IF;
                END IF;
            END;
$$ language plpgsql;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- series search function
CREATE OR REPLACE FUNCTION public.search_series_quick(search_query TEXT, user_id_v VARCHAR)
    RETURNS TABLE(
        series_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v double precision) AS $$
BEGIN
    IF length(search_query) <= 2
    THEN
        RETURN;
    ELSEIF coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE            
        RETURN QUERY
            SELECT 
                series_id, title, poster, average_rating, imdb_rating, popularity, ts_headline(
                    'english', q.title, websearch_to_tsquery('english', search_query), 
                    'MaxFragments=3,MaxWords=25,MinWords=2') highlight, q."rank"
            FROM (
                    SELECT ts_rank(
                            f."search", websearch_to_tsquery('english', search_query)
                        ) 
                        + public.rank_boost_rating (imdb_rating, popularity, 5) 
                        + public.rank_boost_language("language") 
                        + public.rank_boost_series_relese_date(start_year, popularity, 5)
                        + public.rank_boost_recent_viewed(series_id, user_id_v)
                        + public.get_fuzzy_rank (title, search_query) 
                        "rank", *
                    FROM public.series_search f, websearch_to_tsquery('english', search_query) AS tsq
                    WHERE
                        f."search" @@ to_tsquery('english', tsq::TEXT || ':*')
                ) q
            WHERE
                q.rank > 0.001
            ORDER BY "rank" DESC NULLS LAST;
    END IF;        
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION public.search_series_slow(search_query TEXT)
    RETURNS TABLE(
        series_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
        BEGIN
    IF length(search_query) <= 4
    THEN
        RETURN;
    ELSEIF
        coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE    
        RETURN QUERY
        WITH
            ranked_search AS (
                SELECT ts_rank(
                        "search", websearch_to_tsquery('english', search_query)
                    ) 
                    + public.rank_boost_rating (imdb_rating, popularity, 5)
                    "rank", series_id, title, poster, average_rating, imdb_rating, popularity
                FROM public.series_search
                ORDER BY "rank" DESC NULLS LAST
                LIMIT 1000
            )
        SELECT series_id, title, poster, average_rating, imdb_rating, popularity, 
            ts_headline(
                'english', title, websearch_to_tsquery('english', search_query), 'MaxFragments=3,MaxWords=25,MinWords=2'
            ) highlight, "rank"
        FROM ranked_search
        ORDER BY public.get_fuzzy_rank (
                title,
                to_tsquery(
                    'english',
                    websearch_to_tsquery('english', search_query)::TEXT || ':*')::TEXT
                ) DESC;
    END IF;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------------------------------------------------------
--episode search function

CREATE OR REPLACE FUNCTION public.search_episode_quick(search_query TEXT, user_id_v VARCHAR)
    RETURNS TABLE(
        episode_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
BEGIN
    IF length(search_query) <= 2
    THEN
        RETURN;
    ELSEIF coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE            
        RETURN QUERY
            SELECT 
                episode_id, title, poster, average_rating, imdb_rating, popularity, ts_headline(
                    'english', q.title, websearch_to_tsquery('english', search_query), 
                    'MaxFragments=3,MaxWords=25,MinWords=2') highlight, q."rank"
            FROM (
                    SELECT ts_rank(
                            f."search", websearch_to_tsquery('english', search_query)
                        ) 
                        + public.rank_boost_rating (imdb_rating, popularity, 5) 
                        + public.rank_boost_language("language")
                        + public.rank_boost_relese_date(relese_date, CURRENT_DATE, popularity, 5)
                        + public.rank_boost_recent_viewed(episode_id, user_id_v)
                        + public.get_fuzzy_rank (title, search_query) 
                        "rank", *
                    FROM public.episode_search f, websearch_to_tsquery('english', search_query) AS tsq
                    WHERE
                        f."search" @@ to_tsquery('english', tsq::TEXT || ':*')
                ) q
            WHERE
                q.rank > 0.001
            ORDER BY "rank" DESC NULLS LAST;
    END IF;        
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.search_episode_slow(search_query TEXT)
    RETURNS TABLE(
        episode_id_v VARCHAR,
        title_v VARCHAR,
        poster_v VARCHAR,
        average_rating_v NUMERIC,
        imdb_rating_v NUMERIC,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
        BEGIN
    IF length(search_query) <= 4
    THEN
        RETURN;
    ELSEIF
        coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE    
        RETURN QUERY
        WITH
            ranked_search AS (
                SELECT ts_rank(
                        "search", websearch_to_tsquery('english', search_query)
                    ) 
                    + public.rank_boost_rating (imdb_rating, popularity, 5)
                    "rank", episode_id, title, poster, average_rating, imdb_rating, popularity
                FROM public.episode_search
                ORDER BY "rank" DESC NULLS LAST
                LIMIT 1000
            )
        SELECT episode_id, title, poster, average_rating, imdb_rating, popularity, 
            ts_headline(
                'english', title, websearch_to_tsquery('english', search_query), 'MaxFragments=3,MaxWords=25,MinWords=2'
            ) highlight, "rank"
        FROM ranked_search
        ORDER BY public.get_fuzzy_rank (
                title,
                to_tsquery(
                    'english',
                    websearch_to_tsquery('english', search_query)::TEXT || ':*')::TEXT
                ) DESC;
    END IF;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------------------------------------------------------
--person search function
CREATE OR REPLACE FUNCTION public.search_person_quick(search_query TEXT, user_id_v VARCHAR)
    RETURNS TABLE(
        person_id_v VARCHAR,
        name_v VARCHAR,
        primary_profession_v VARCHAR,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
BEGIN
    IF length(search_query) <= 2
    THEN
        RETURN;
    ELSEIF coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE            
        RETURN QUERY
            SELECT 
                person_id, "name", primary_profession, popularity, ts_headline(
                    'english', q.name, websearch_to_tsquery('english', search_query), 
                    'MaxFragments=3,MaxWords=25,MinWords=2') highlight, q."rank"
            FROM (
                    SELECT ts_rank(
                            f."search", websearch_to_tsquery('english', search_query)
                        ) 
                        + public.rank_boost_rating ((0.005*popularity), popularity, 5)
                        + public.rank_boost_recent_viewed(person_id, user_id_v)
                        + public.get_fuzzy_rank ("name", search_query) 
                        "rank", *
                    FROM public.person_search f, websearch_to_tsquery('english', search_query) AS tsq
                    WHERE
                        f."search" @@ to_tsquery('english', tsq::TEXT || ':*')
                ) q
            WHERE
                q.rank > 0.001
            ORDER BY "rank" DESC NULLS LAST;
    END IF;        
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION public.search_person_slow(search_query TEXT)
    RETURNS TABLE(
        person_id_v VARCHAR,
        name_v VARCHAR,
        primary_profession_v VARCHAR,
        popularity_v BIGINT,
        highlight_v TEXT,
        rank_v DOUBLE PRECISION) AS $$
        BEGIN
    IF length(search_query) <= 4
    THEN
        RETURN;
    ELSEIF
        coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    ELSE    
        RETURN QUERY
        WITH
            ranked_search AS (
                SELECT ts_rank(
                        "search", websearch_to_tsquery('english', search_query)
                    ) 
                    + public.rank_boost_rating ((0.05*popularity), popularity, 5)
                    "rank", person_id, "name", primary_profession, popularity
                FROM public.person_search
                ORDER BY "rank" DESC NULLS LAST
                LIMIT 1000
            )
        SELECT person_id, "name", primary_profession, popularity, 
            ts_headline(
                'english', "name", websearch_to_tsquery('english', search_query), 'MaxFragments=3,MaxWords=25,MinWords=2'
            ) highlight, "rank"
        FROM ranked_search
        ORDER BY public.get_fuzzy_rank (
                "name",
                to_tsquery(
                    'english',
                    websearch_to_tsquery('english', search_query)::TEXT || ':*')::TEXT
                ) DESC;
    END IF;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------ALL SEARCH
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.search_all(search_query TEXT, user_id_v VARCHAR)
    RETURNS TABLE(
        type_s VARCHAR,
        id_s VARCHAR,
        title_s VARCHAR,
        poster_s VARCHAR,
        average_rating_s NUMERIC,
        imdb_rating_s NUMERIC,
        popularity_s BIGINT,
        highlight_s TEXT,
        rank_s DOUBLE PRECISION) AS $$  
BEGIN
    IF length(search_query) <= 2
    THEN
        RETURN;
    ELSEIF coalesce(websearch_to_tsquery('english', search_query), '') = ''
    THEN
        RETURN;
    END IF;

    IF EXISTS(
            SELECT true
            FROM public.search_movie_quick(search_query, user_id_v)
            WHERE rank_v > 1.5
            LIMIT 1
        )
    THEN 
        RETURN QUERY
            SELECT 
                'movieq'::varchar AS type_v, movie_id_v, title_v, poster_v, average_rating_v, imdb_rating_v, popularity_v, highlight_v, rank_v
            FROM public.search_movie_quick(search_query, user_id_v);
    ELSEIF EXISTS(
            SELECT true
            FROM public.search_series_quick(search_query, user_id_v)
            WHERE rank_v > 1.5
            LIMIT 1
        )
    THEN 
        RETURN QUERY
            SELECT 
                'seriesq'::varchar AS type_v, series_id_v, title_v, poster_v, average_rating_v, imdb_rating_v, popularity_v, highlight_v, rank_v
            FROM public.search_series_quick(search_query, user_id_v);
    ELSEIF EXISTS(
            SELECT true
            FROM public.search_episode_quick(search_query, user_id_v)
            WHERE rank_v > 1.5
            LIMIT 1
        )
    THEN 
        RETURN QUERY
            SELECT 
                'episodeq'::varchar AS type_v, episode_id_v, title_v, poster_v, average_rating_v, imdb_rating_v, popularity_v, highlight_v, rank_v
            FROM public.search_episode_quick(search_query, user_id_v);
    ELSEIF EXISTS(
        SELECT
            true
        FROM public.search_person_quick(search_query, user_id_v)
        WHERE rank_v > 1.5
        LIMIT 1
    )
    THEN
        RETURN QUERY
            SELECT
                'personq'::varchar AS type_v, person_id_v, name_v, ''::varchar, 0.0, 0.0, popularity_v, highlight_v, rank_v
            FROM public.search_person_quick(search_query, user_id_v);
    ELSEIF EXISTS(
            (SELECT
                true
            FROM public.search_movie_quick(search_query, user_id_v)
            LIMIT 1)
            UNION ALL
            (SELECT
                true
            FROM public.search_series_quick(search_query, user_id_v)
            LIMIT 1)
            UNION ALL
            (SELECT
                true
            FROM public.search_episode_quick(search_query, user_id_v)
            LIMIT 1)
            UNION ALL
            SELECT
                true
            FROM public.search_person_quick(search_query, user_id_v)
        LIMIT 1
        )
    THEN 
        RETURN QUERY
            SELECT
                'movieq'::varchar AS type_v, movie_id_v, title_v, poster_v, average_rating_v, imdb_rating_v, popularity_v, highlight_v, rank_v
            FROM public.search_movie_quick(search_query, user_id_v)
            UNION ALL
            SELECT
                'seriesq'::varchar AS type_v, series_id_v, title_v, poster_v, average_rating_v, imdb_rating_v, popularity_v, highlight_v, rank_v
            FROM public.search_series_quick(search_query, user_id_v)
            UNION ALL
            SELECT
                'episodeq'::varchar AS type_v, episode_id_v, title_v, poster_v, average_rating_v, imdb_rating_v, popularity_v, highlight_v, rank_v
            FROM public.search_episode_quick(search_query, user_id_v)
            UNION ALL
            SELECT
                'personq'::varchar AS type_v, person_id_v, name_v, ''::varchar, 0.0, 0.0, popularity_v, highlight_v, rank_v
            FROM public.search_person_quick(search_query, user_id_v)
        ORDER BY rank_v DESC NULLS LAST;
    ELSE
        RETURN QUERY
       (SELECT
            'movie'::varchar AS type_v,
            movie_id_v AS id_v,
            title_v,
            poster_v,
            average_rating_v, 
            imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_movie_slow(search_query)
        LIMIT 50)
        UNION ALL
        (SELECT
            'series'::varchar AS type_v,
            series_id_v AS id_v,
            title_v,
            poster_v,
            average_rating_v,
            imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_series_slow(search_query)
        LIMIT 50)
        UNION ALL
        (SELECT
            'episode'::varchar AS type_v,
            episode_id_v AS id_v,
            title_v,
            poster_v,
            average_rating_v,
            imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_episode_slow(search_query)
        LIMIT 50)
        UNION ALL
        (SELECT
            'person'::varchar AS type_v,
            person_id_v AS id_v,
            name_v,
            ''::varchar AS poster_v,
            0.0 AS average_rating_v,
            0.0 AS imdb_rating_v,
            popularity_v,
            highlight_v,
            rank_v
        FROM public.search_person_slow(search_query)
        LIMIT 50);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM public.search_all('the biag sur', 'ur00022837');