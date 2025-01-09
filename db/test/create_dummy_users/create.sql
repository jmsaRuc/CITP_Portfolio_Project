-- Active: 1727253378954@@127.0.0.1@5532@portf_1

------------------------------------------------------------------------------------------
--create dummy users that have watchlists, ratings, and recent views, and populate top_this_week
------------------------------------------------------------------------------------------
---
--the recent_view loop is weighted to favor the same titels as imdb_rating counts using public.get_random_type()
--makeing the top_this_week and popularity values more realistic

--run this script via ./create_dummy_users.sh

-----------------------------------------------------------------------------------
--create public.get_random_type()----------------------

---make sure title_ratings and type align

with type_no_person as (
    SELECT "type_id" as tconst
    FROM public."type"
    WHERE "title_type" != 'person'
), title_ratings_filtered as (
    SELECT * 
    FROM public.title_ratings NATURAL JOIN type_no_person
)
DELETE
FROM public.title_ratings
WHERE tconst not IN (SELECT tconst FROM title_ratings_filtered);

-----create title_ratings probability columns and populate them
ALTER TABLE public.title_ratings
ADD COLUMN numvotes_weights NUMERIC,
ADD COLUMN numvote_probability NUMERIC,
ADD COLUMN startprobability NUMERIC,
ADD COLUMN endprobability NUMERIC;

--normalize numvotes
UPDATE public.title_ratings
SET numvotes_weights = ((numvotes - numvotes_stats.min_x)) / NULLIF((numvotes_stats.max_x - numvotes_stats.min_x), 0)::numeric
FROM (SELECT
        MIN(numvotes) AS min_x,
        MAX(numvotes) AS max_x
     FROM
        public.title_ratings) AS numvotes_stats;

---calculate probability
WITH p AS ( 
    SELECT *, numvotes_weights / (SELECT sum(numvotes_weights)
    FROM public.title_ratings) as probability
    FROM public.title_ratings
)
UPDATE public.title_ratings
SET numvote_probability = p.probability
FROM p
WHERE public.title_ratings.tconst = p.tconst;

---calculate start and end probability
with cp AS (
    SELECT *,
        sum(numvote_probability) OVER (
            ORDER BY numvote_probability DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) cumprobability
    FROM title_ratings
)
UPDATE title_ratings
SET 
   startprobability = cp.cumprobability - cp.numvote_probability,
   endprobability = cp.cumprobability
FROM cp
WHERE title_ratings.tconst = cp.tconst;


--------------create public.get_random_type()----------------------


CREATE OR REPLACE FUNCTION public.get_random_type(p_random FLOAT8 = random())
RETURNS VARCHAR AS
$$
    SELECT tconst
    FROM public.title_ratings
    WHERE p_random BETWEEN startprobability AND endprobability
    ;
$$ LANGUAGE SQL STABLE STRICT;

-----------------------------------------------------------------------------------------
--create dummy users

#DO $$
#BEGIN
#    FOR i IN 1..1000 LOOP
#        INSERT INTO public."user" (username, "password", salt, email)
#        VALUES (
#            'usr' || i,
#            sha256(('usr' || i)::bytea),
#            sha256(('usr' || i || '@example.com')::bytea),
#            'usr' || i || '@example.com'
#        );
#    END LOOP;
#END $$;

DO $$
DECLARE
    movie_ids text[];
    series_ids text[];
    episode_ids text[];
    type_ids text[];
    new_user_id text;
    random_int int;
    random_int2 int;
    weighted_random_type_id VARCHAR;
BEGIN
    -- Get movie_ids, series_ids, episode_ids, and type_ids
    SELECT array_agg(movie_id) INTO movie_ids FROM public.movie;
    SELECT array_agg(series_id) INTO series_ids FROM public.series;
    SELECT array_agg(episode_id) INTO episode_ids FROM public.episode;

    FOR i IN 1..1000 LOOP
        new_user_id := (SELECT "user_id" FROM public."user" WHERE username = 'usr' || i);

        -- Insert 10 user_movie_watchlist
        FOR j IN 1..10 LOOP
            INSERT INTO public.user_movie_watchlist("user_id", movie_id) 
            VALUES (
                new_user_id,
                movie_ids[(i+j)::int]
            ) ON CONFLICT ("user_id", movie_id) DO UPDATE SET
                "user_id" = new_user_id,
                movie_id = movie_ids[(i+j)::int];
        END LOOP;

        -- Insert 10 user_series_watchlist
        FOR j IN 1..10 LOOP
            random_int := floor(random() * (1000)+1)::int;
            INSERT INTO public.user_series_watchlist("user_id", series_id)
            VALUES (
                new_user_id,
                series_ids[random_int]
            ) ON CONFLICT ("user_id", series_id) DO UPDATE SET
                "user_id" = new_user_id,
                series_id = series_ids[random_int];
        END LOOP;

        -- Insert 10 user_episode_watchlist
        FOR j IN 1..10 LOOP
            INSERT INTO public.user_episode_watchlist("user_id", episode_id)
             VALUES (
                new_user_id,
                episode_ids[(i+j)::int]
            ) ON CONFLICT ("user_id", episode_id) DO UPDATE SET
                "user_id" = new_user_id,
                episode_id = episode_ids[(i+j)::int];
        END LOOP;

        -- Insert 10 recent_views
        FOR j IN 1..10 LOOP
            weighted_random_type_id := public.get_random_type();
            INSERT INTO public.recent_view ("user_id", "type_id")
            VALUES (
                new_user_id,
                weighted_random_type_id 
            ) ON CONFLICT ("user_id", "type_id") DO UPDATE SET
                "user_id" = new_user_id,
                "type_id" = weighted_random_type_id;
        END LOOP;

        FOR j IN 1..10 LOOP
            random_int := floor(random() * (10) + 1)::int;
            INSERT INTO public.user_movie_rating ("user_id", movie_id, rating)
            VALUES (
                new_user_id,
                movie_ids[(i+j)::int],
                random_int 
            ) ON CONFLICT ("user_id", movie_id) DO UPDATE SET
                "user_id" = new_user_id,
                movie_id = movie_ids[(i+j)::int],
                rating = random_int;
        END LOOP;

        FOR j IN 1..10 LOOP
            random_int := floor(random() * (10) + 1)::int;
            random_int2 := floor(random() * (1000) +1 )::int;
            INSERT INTO public.user_series_rating ("user_id", series_id, rating)
            VALUES (
                new_user_id,
                series_ids[random_int2],
                random_int
            ) ON CONFLICT ("user_id", series_id) DO UPDATE SET
                "user_id" = new_user_id,
                series_id = series_ids[ random_int2],
                rating = random_int;
        END LOOP;

        FOR j IN 1..10 LOOP
            random_int := floor(random() * (10) + 1)::int;
            INSERT INTO public.user_episode_rating ("user_id", episode_id, rating)
            VALUES (
                new_user_id,
                episode_ids[(i+j)::int],
                random_int
            ) ON CONFLICT ("user_id", episode_id) DO UPDATE SET
                "user_id" = new_user_id,
                episode_id = episode_ids[(i+j)::int],
                rating = random_int;
        END LOOP;           
    END LOOP;
END $$ LANGUAGE plpgsql;

--refresh top_this_week
REFRESH MATERIALIZED VIEW public.top_this_week;

---------------drop public.get_random_type() and title_ratings----------------------

DROP FUNCTION if EXISTS public.get_random_type;

DROP TABLE if EXISTS public.title_ratings;

-----------clean up
DROP TABLE IF EXISTS public.title_akas;

DROP TABLE IF EXISTS public.title_crew;

DROP TABLE IF EXISTS public.title_basics;

DROP TABLE IF EXISTS public.title_episode;

DROP TABLE IF EXISTS public.title_principals;

DROP TABLE IF EXISTS public.name_basics;