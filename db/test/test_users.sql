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

INSERT INTO
    public.user (
        user_id,
        username,
        password,
        email,
        created_at
    )
VALUES (
        'ur00000101',
        'admin',
        decode(md5('admin'), 'hex'),
        'user00000101@example.com',
        current_date
    );

INSERT INTO
    public.user_episode_interaction (
        user_id,
        episode_id,
        watchlist
    )
VALUES ('ur00000101', 'tt12768346', 1);

UPDATE public.user_episode_interaction
SET
    rating = 10
WHERE
    user_id = 'ur00000101';

-- Find duplicate rows in the movie_language table
SELECT movie_id, language, COUNT(*)
FROM movie_language
GROUP BY
    movie_id,
    language
HAVING
    COUNT(*) > 1;

SELECT * FROM omdb_data WHERE tconst = 'tt3795628';

-- test movie type trigger
INSERT INTO
    movie (
        movie_id,
        title,
        re_year,
        run_time,
        poster,
        plot,
        release_date,
        imdb_rating
    )
VALUES (
        'tt32459823',
        'The Revenant',
        2015,
        '156 m',
        'https://m.media-amazon.com/images/I/71r8ZLZqjwL._AC_SY679_.jpg',
        'A frontiersman on a fur trading expedition in the 1820s fights for survival after being mauled by a bear and left for dead by members of his own hunting team.',
        '2016-01-08',
        8.0
    )
RETURNING
    *;

SELECT * FROM type WHERE type_id = 'tt32459823';

DELETE FROM movie WHERE movie_id = 'tt32459823';


-- test series type trigger
INSERT INTO
    series (
        series_id,
        title,
        start_year,
        end_year,
        poster,
        plot,
        imdb_rating
    )
VALUES (
        'tt32459824',
        'Breaking Bad',
        2008,
        2013,
        'https://m.media-amazon.com/images/I/71r8ZLZqjwL._AC_SY679_.jpg',
        'A high school chemistry teacher diagnosed with inoperable lung cancer turns to manufacturing and selling methamphetamine in order to secure his family''s future.',
        9.5
    )

SELECT * FROM type WHERE type_id = 'tt32459824';

DELETE FROM series WHERE series_id = 'tt32459824';

SELECT * FROM episode_series WHERE series_id = 'tt32459824';



-- test episode type trigger

INSERT INTO
    episode (
        episode_id,
        title,
        re_year,
        run_time,
        plot,
        relese_date,
        imdb_rating
    )
VALUES (
        'tt32459825',
        'Pilot',
        2008,
        '58 m',
        'Diagnosed with terminal lung cancer, a high school chemistry teacher resorts to cooking and selling methamphetamine to provide for his family.',
        '2008-01-20',
        9.0
    )

SELECT * FROM type WHERE type_id = 'tt32459825';

DELETE FROM episode WHERE episode_id = 'tt32459825';


----------------------test user functionality----------------------
SELECT public.create_user('test_user', sha256('foo'::bytea), 'test_user@gmail.com');

SELECT new_watchlist_movie('ur00000101', 'tt32459823');

SELECT UPDATE


SELECT public.delete_user('test_user');





