-- Active: 1727253378954@@127.0.0.1@5532@portf_1

------------------------------------------------------------------------------------------
--multi user test
------------------------------------------------------------------------------------------


DO $$
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO public."user" (username, "password", salt, email)
        VALUES (
            'usr' || i,
            sha256(('usr' || i)::bytea),
            sha256(('usr' || i || '@example.com')::bytea),
            'usr' || i || '@example.com'
        );
    END LOOP;
END $$;

DO $$
DECLARE
    movie_ids text[];
    series_ids text[];
    episode_ids text[];
    type_ids text[];
    new_user_id text;
    random_int int;
    random_int2 int;
BEGIN
    -- Get movie_ids, series_ids, episode_ids, and type_ids
    SELECT array_agg(movie_id) INTO movie_ids FROM public.movie;
    SELECT array_agg(series_id) INTO series_ids FROM public.series;
    SELECT array_agg(episode_id) INTO episode_ids FROM public.episode;
    SELECT array_agg("type_id" ORDER BY random()) INTO type_ids FROM public.type;

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
            random_int := floor(random() * (500000 ) + 1)::int;
            INSERT INTO public.recent_view ("user_id", "type_id")
            VALUES (
                new_user_id,
                type_ids[random_int]
            ) ON CONFLICT ("user_id", "type_id") DO UPDATE SET
                "user_id" = new_user_id,
                "type_id" = type_ids[random_int];
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

SELECT COUNT(*)
FROM public.movie
WHERE
    popularity > 0

DELETE FROM public."user"
WHERE
    username LIKE 'usr%';

REFRESH MATERIALIZED VIEW public.top_this_week;





    