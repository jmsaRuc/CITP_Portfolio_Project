-- Active: 1727253378954@@127.0.0.1@5532@portf_1@pgtap

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Data base test
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

SET search_path TO pgtap, public;

BEGIN;

SELECT pgtap.plan (26);
---CREATE OR REPLACE FUNCTION public.test()

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
    SELECT array_agg("type_id") INTO type_ids FROM public.type;

    FOR i IN 1..100 LOOP
        new_user_id := 'ur' || LPAD(i::text, 8, '0');

        -- Insert 10 user_movie_interactions
        FOR j IN 1..10 LOOP
            INSERT INTO public.user_movie_interaction ("user_id", movie_id, rating, watchlist) 
            VALUES (
                new_user_id,
                movie_ids[(random() * array_length(movie_ids, 1) + 1)::int],
                (random() * 9 + 1)::int,
                (random() * 10 + 1)::int
            ) ON CONFLICT ("user_id", movie_id) DO UPDATE SET
                rating = EXCLUDED.rating,
                watchlist = EXCLUDED.watchlist;
        END LOOP;

        -- Insert 2 user_series_interactions
        FOR j IN 1..2 LOOP
            INSERT INTO public.user_series_interaction ("user_id", series_id, rating, watchlist)
            VALUES (
                new_user_id,
                series_ids[(random() * array_length(series_ids, 1) + 1)::int],
                (random() * 9 + 1)::int,
                (random() * 10 + 1)::int
            ) ON CONFLICT ("user_id", series_id) DO UPDATE SET
                rating = EXCLUDED.rating,
                watchlist = EXCLUDED.watchlist;
        END LOOP;

        -- Insert 10 user_episode_interactions
        FOR j IN 1..10 LOOP
            INSERT INTO public.user_episode_interaction ("user_id", episode_id, rating, watchlist)
             VALUES (
                new_user_id,
                episode_ids[(random() * array_length(episode_ids, 1) + 1)::int],
                (random() * 9 + 1)::int,
                (random() * 10 + 1)::int
            ) ON CONFLICT ("user_id", episode_id) DO UPDATE SET
                rating = EXCLUDED.rating,
                watchlist = EXCLUDED.watchlist; 
        END LOOP;

        -- Insert 10 recent_views
        FOR j IN 1..10 LOOP
            INSERT INTO public.recent_view ("user_id", title_type, "type_id", view_ordering)
            VALUES (
                new_user_id,
                (ARRAY['movie', 'series', 'episode', 'person'])[(random() * 3 + 1)::int],
                type_ids[(random() * array_length(type_ids, 1) + 1)::int],
                j
            ) ON CONFLICT ("user_id", "type_id") DO UPDATE SET
                view_ordering = EXCLUDED.view_ordering,
                title_type = EXCLUDED.title_type;
        END LOOP;
    END LOOP;
END $$ LANGUAGE plpgsql;

----test duymmy users----

SELECT pgtap.ok (
        (
            SELECT COUNT(*)
            FROM public."user"
        ) = 100, '100 users created'
    );

SELECT pgtap.is (
        (
            SELECT count(*)
            FROM public.user_movie_interaction
            GROUP BY
                "user_id", movie_id, rating, watchlist
            HAVING
                count(*) > 1
        ), NULL, 'No duplicate entries in user_movie_interaction'
    );

SELECT pgtap.is (
        (
            SELECT count(*)
            FROM public.user_series_interaction
            GROUP BY
                "user_id", series_id, rating, watchlist
            HAVING
                count(*) > 1
        ), NULL, 'No duplicate entries in user_series_interaction'
    );

SELECT pgtap.is (
        (
            SELECT count(*)
            FROM public.user_episode_interaction
            GROUP BY
                "user_id", episode_id, rating, watchlist
            HAVING
                count(*) > 1
        ), NULL, 'No duplicate entries in user_episode_interaction'
    );

-- test type trigger --------------------------------------------
INSERT INTO
    public.movie (
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
    );

SELECT pgtap.is (
        (
            SELECT title_type
            FROM public.type
            WHERE
                "type_id" = 'tt32459823'
        ), 'movie', 'Movie type trigger'
    );

SELECT pgtap.is (
        (
            SELECT title_type
            FROM public.type
            WHERE
                "type_id" = 'tt0903747'
        ), 'series', 'Series type trigger'
    );

INSERT INTO
    public.series (
        series_id,
        title,
        start_year,
        end_year,
        poster,
        plot,
        imdb_rating
    )
VALUES (
        'tt4574334',
        'Stranger Things',
        2016,
        NULL,
        'https://m.media-amazon.com/images/I/71r8ZLZqjwL._AC_SY679_.jpg',
        'In 1980s Indiana, a group of young friends witness supernatural forces and secret government exploits. As they search for answers, the children unravel a series of extraordinary mysteries.',
        8.7
    );

SELECT pgtap.is (
        (
            SELECT title_type
            FROM public.type
            WHERE
                "type_id" = 'tt4574334'
        ), 'series', 'Series type trigger'
    );

SELECT pgtap.is (
        (
            SELECT title_type
            FROM public.type
            WHERE
                "type_id" = 'tt0959621'
        ), 'episode', 'Episode type trigger'
    );

INSERT INTO
    public.episode (
        episode_id,
        title,
        re_year,
        run_time,
        plot,
        relese_date,
        imdb_rating
    )
VALUES (
        'tt4593118',
        'Chapter One: The Vanishing of Will Byers',
        2016,
        '48 m',
        'On his way home from a friend''s house, young Will sees something terrifying. Nearby, a sinister secret lurks in the depths of a government lab.',
        '2016-07-15',
        8.4
    );

SELECT pgtap.is (
        (
            SELECT title_type
            FROM public.type
            WHERE
                "type_id" = 'tt4593118'
        ), 'episode', 'Episode type trigger'
    );

-- test user functionality --------------------------------------------

SELECT pgtap.is (
        (
            SELECT public.create_user (
                    'test_user', sha256('foo'::bytea), 'test_user@gmail.com'
                )
        ), TRUE, 'User created'
    );

SELECT pgtap.is (
        (
            SELECT username
            FROM public."user"
            WHERE
                username = 'test_user'
        ), 'test_user', 'Username is test_user'
    );
-- add to watchlist --------------------------------------------
SELECT pgtap.is (
        (
            SELECT public.new_watchlist_movie ('ur00000101', 'tt32459823')
        ), TRUE, 'Movie added to watchlist'
    );

SELECT pgtap.is (
        (
            SELECT public.new_watchlist_movie ('ur00000101', 'tt1596363')
        ), TRUE, 'Movie added to watchlist'
    );

SELECT pgtap.is (
        (
            SELECT public.new_watchlist_series ('ur00000101', 'tt0903747')
        ), TRUE, 'Series added to watchlist'
    );

SELECT pgtap.is (
        (
            SELECT public.new_watchlist_series ('ur00000101', 'tt4574334')
        ), TRUE, 'Series added to watchlist'
    );

SELECT pgtap.is (
        (
            SELECT public.new_watchlist_episode ('ur00000101', 'tt0959621')
        ), TRUE, 'Episode added to watchlist'
    );

SELECT pgtap.is (
        (
            SELECT public.new_watchlist_episode ('ur00000101', 'tt4593118')
        ), TRUE, 'Episode added to watchlist'
    );

-- add rating, to watchlist --------------------------------------------

------to do

-- test if watchlist is working --------------------------------------------

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_movie_interaction
            WHERE
                user_id = 'ur00000101'
        ) = 2, '2 movies in watchlist'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_series_interaction
            WHERE
                user_id = 'ur00000101'
        ) = 2, '2 series in watchlist'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_episode_interaction
            WHERE
                user_id = 'ur00000101'
        ) = 2, '2 episodes in watchlist'
    );

-- test watchlist delete, when user delet --------------------------------------------
SELECT pgtap.is (
        (
            SELECT public.delete_user ('test_user')
        ), TRUE, 'User deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_movie_interaction
            WHERE
                user_id = 'ur00000101'
        ) = 0, 'Movies deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_series_interaction
            WHERE
                user_id = 'ur00000101'
        ) = 0, 'Series deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_episode_interaction
            WHERE
                user_id = 'ur00000101'
        ) = 0, 'Episodes deleted'
    );
-- test search functions --------------------------------------------

SELECT pgtap.is (
        (
            SELECT title
            FROM public.string_search ('the biG short')
        ), 'The Big Short', 'string search, Search for movie'
    );

SELECT pg_sleep(1);

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.find_co_players ('Bryan Cranston')
            WHERE
                co_actor = 'Bill Murray'
        ) > 0, 'find co players'
    );

SELECT pg_sleep(1);

-- clean up --------------------------------------------
DELETE FROM public.movie WHERE movie_id = 'tt32459823';

DELETE FROM public.series WHERE series_id = 'tt4574334';

DELETE FROM public.episode WHERE episode_id = 'tt4593118';

DELETE FROM public."user"
WHERE
    "user_id" IN (
        NULL,
        'ur00000001',
        'ur00000002',
        'ur00000003',
        'ur00000004',
        'ur00000005',
        'ur00000006',
        'ur00000007',
        'ur00000008',
        'ur00000009',
        'ur00000010',
        'ur00000011',
        'ur00000012',
        'ur00000013',
        'ur00000014',
        'ur00000015',
        'ur00000016',
        'ur00000017',
        'ur00000018',
        'ur00000019',
        'ur00000020',
        'ur00000021',
        'ur00000022',
        'ur00000023',
        'ur00000024',
        'ur00000025',
        'ur00000026',
        'ur00000027',
        'ur00000028',
        'ur00000029',
        'ur00000030',
        'ur00000031',
        'ur00000032',
        'ur00000033',
        'ur00000034',
        'ur00000035',
        'ur00000036',
        'ur00000037',
        'ur00000038',
        'ur00000039',
        'ur00000040',
        'ur00000041',
        'ur00000042',
        'ur00000043',
        'ur00000044',
        'ur00000045',
        'ur00000046',
        'ur00000047',
        'ur00000048',
        'ur00000049',
        'ur00000050',
        'ur00000051',
        'ur00000052',
        'ur00000053',
        'ur00000054',
        'ur00000055',
        'ur00000056',
        'ur00000057',
        'ur00000058',
        'ur00000059',
        'ur00000060',
        'ur00000061',
        'ur00000062',
        'ur00000063',
        'ur00000064',
        'ur00000065',
        'ur00000066',
        'ur00000067',
        'ur00000068',
        'ur00000069',
        'ur00000070',
        'ur00000071',
        'ur00000072',
        'ur00000073',
        'ur00000074',
        'ur00000075',
        'ur00000076',
        'ur00000077',
        'ur00000078',
        'ur00000079',
        'ur00000080',
        'ur00000081',
        'ur00000082',
        'ur00000083',
        'ur00000084',
        'ur00000085',
        'ur00000086',
        'ur00000087',
        'ur00000088',
        'ur00000089',
        'ur00000090',
        'ur00000091',
        'ur00000092',
        'ur00000093',
        'ur00000094',
        'ur00000095',
        'ur00000096',
        'ur00000097',
        'ur00000098',
        'ur00000099',
        'ur00000100'
    );

SELECT * FROM pgtap.finish ();

END;

