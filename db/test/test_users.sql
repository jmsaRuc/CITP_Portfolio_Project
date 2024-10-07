-- Active: 1727253378954@@127.0.0.1@5532@portf_1

-- Insert 100 users
DO $$
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO public.user (user_id, username, password, email, created_at)
        VALUES (
            'ur' || LPAD(i::text, 8, '0'),
            'user' || i,
            decode(md5(random()::text), 'hex'),
            'user' || i || '@example.com',
            current_date
        );
    END LOOP;
END $$;

-- Insert 10 interactions and 10 recent views for each user
DO $$
DECLARE
    movie_ids text[];
    series_ids text[];
    episode_ids text[];
    type_ids text[];
    new_user_id text;
BEGIN
    -- Get movie_ids, series_ids, episode_ids, and type_ids
    SELECT array_agg(movie_id) INTO movie_ids FROM public.movie;
    SELECT array_agg(series_id) INTO series_ids FROM public.series;
    SELECT array_agg(episode_id) INTO episode_ids FROM public.episode;
    SELECT array_agg(type_id) INTO type_ids FROM public.type;

    FOR i IN 1..100 LOOP
        new_user_id := 'ur' || LPAD(i::text, 8, '0');

        -- Insert 10 user_movie_interactions
        FOR j IN 1..10 LOOP
            INSERT INTO public.user_movie_interaction (user_id, movie_id, rating, watchlist) 
            VALUES (
                new_user_id,
                movie_ids[(random() * array_length(movie_ids, 1) + 1)::int],
                (random() * 9 + 1)::int,
                (random() * 10 + 1)::int
            ) ON CONFLICT (user_id, movie_id) DO UPDATE SET
                rating = EXCLUDED.rating,
                watchlist = EXCLUDED.watchlist;
        END LOOP;

        -- Insert 10 user_series_interactions
        FOR j IN 1..10 LOOP
            INSERT INTO public.user_series_interaction (user_id, series_id, rating, watchlist)
            VALUES (
                new_user_id,
                series_ids[(random() * array_length(series_ids, 1) + 1)::int],
                (random() * 9 + 1)::int,
                (random() * 10 + 1)::int
            ) ON CONFLICT (user_id, series_id) DO UPDATE SET
                rating = EXCLUDED.rating,
                watchlist = EXCLUDED.watchlist;
        END LOOP;

        -- Insert 10 user_episode_interactions
        FOR j IN 1..10 LOOP
            INSERT INTO public.user_episode_interaction (user_id, episode_id, rating, watchlist)
             VALUES (
                new_user_id,
                episode_ids[(random() * array_length(episode_ids, 1) + 1)::int],
                (random() * 9 + 1)::int,
                (random() * 10 + 1)::int
            ) ON CONFLICT (user_id, episode_id) DO UPDATE SET
                rating = EXCLUDED.rating,
                watchlist = EXCLUDED.watchlist; 
        END LOOP;

        -- Insert 10 recent_views
        FOR j IN 1..10 LOOP
            INSERT INTO public.recent_view (user_id, title_type, type_id, view_ordering)
            VALUES (
                new_user_id,
                (ARRAY['movie', 'series', 'episode', 'person'])[(random() * 3 + 1)::int],
                type_ids[(random() * array_length(type_ids, 1) + 1)::int],
                j
            );
        END LOOP;
    END LOOP;
END $$;

INSERT INTO public.user (user_id, username, password, email, created_at)
VALUES ('ur00000101', 'admin', decode(md5('admin'), 'hex'), 'user00000101@example.com', current_date);

INSERT INTO public.user_episode_interaction (user_id, episode_id, watchlist)
VALUES ('ur00000101', 'tt12768346', 1);

UPDATE public.user_episode_interaction
SET rating = 10
WHERE user_id = 'ur00000101';


-- Find duplicate rows in the movie_language table
SELECT movie_id, language, COUNT(*)
FROM movie_language
GROUP BY movie_id, language
HAVING COUNT(*) > 1;

SELECT *
FROM omdb_data
WHERE tconst = 'tt3795628';