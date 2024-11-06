-- Active: 1727253378954@@127.0.0.1@5532@portf_1@public

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Data base test
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

SET search_path TO pgtap, public;

BEGIN;

SELECT pgtap.plan (35);

--------------------------------------------------------------------------------
-- singel user test
--------------------------------------------------------------------------------

INSERT INTO
    public."user" (
        username,
        "password",
        salt,
        email
    )
VALUES (
        'test_user',
        sha256('foo'::bytea),
        sha256('asdw'::bytea),
        'wup@gmail.com'
    );

INSERT INTO
    public."user" (
        username,
        "password",
        salt,
        email
    )
VALUES (
        'test_user2',
        sha256('foo'::bytea),
        sha256('asdw'::bytea),
        'wup123@gmail.com'
    );

DELETE FROM "user" WHERE username = 'test_user';

INSERT INTO
    public."user" (
        username,
        "password",
        salt,
        email
    )
VALUES (
        'test_user',
        sha256('foo'::bytea),
        sha256('asdw'::bytea),
        'wup@gmail.com'
    );

-- shoud be ur00000003
SELECT pgtap.is (
        (
            SELECT user_id
            FROM public."user"
            WHERE
                username = 'test_user'
        ), (
            SELECT "user_id"
            FROM public."user"
            WHERE
                username = 'test_user'
        ), 'User creating test'
    );

;

-- test recent view
INSERT INTO
    public.recent_view ("user_id", "type_id")
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),'tt18339924');

INSERT INTO
    public.recent_view ("user_id", "type_id")
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),'tt26476058');

-- should be 2
SELECT pgtap.ok (
        (
            SELECT view_ordering
            FROM public.recent_view
            WHERE
                user_id = (
                    SELECT user_id
                    FROM public.user
                    WHERE
                        username = 'test_user'
                )
                AND type_id = 'tt26476058'
        ) >= 2, 'Recent view test'
    );

---- test recent trigger ------------------

SELECT pgtap.ok (
        (
            SELECT popularity
            FROM public.movie
            WHERE
                movie_id = 'tt18339924'
        ) >= 1, 'popularity populated movie test'
    );

SELECT pgtap.ok (
        (
            SELECT popularity
            FROM public.series
            WHERE
                series_id = 'tt26476058'
        ) >= 1, 'popularity populated series test'
    );

------------------test recent view delete (trigger also) ----------------------------
DELETE FROM public."user"
WHERE
    user_id = (
        SELECT user_id
        FROM public.user
        WHERE
            username = 'test_user'
    );

-- sjould be NUll
SELECT pgtap.is (
        (
            SELECT view_ordering
            FROM public.recent_view
            WHERE
                user_id = (
                    SELECT user_id
                    FROM public.user
                    WHERE
                        username = 'test_user'
                )
                AND type_id = 'tt26476058'
        ), NULL, 'User deleted'
    );

SELECT pgtap.is (
        (
            SELECT popularity
            FROM public.movie
            WHERE
                movie_id = 'tt18339924'
        ), NULL, 'popularity delet movie test'
    );

SELECT pgtap.is (
        (
            SELECT popularity
            FROM public.series
            WHERE
                series_id = 'tt26476058'
        ), NULL, 'popularity delet series test'
    );

INSERT INTO
    public."user" (
        username,
        "password",
        salt,
        email
    )
VALUES (
        'test_user',
        sha256('foo'::bytea),
        sha256('asdw'::bytea),
        'wup@gmail.com'
    );

INSERT INTO
    public.recent_view ("user_id", "type_id")
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        'tt18339924'
    );

-- should be 1 higher then the last one

SELECT pgtap.ok (
        (
            SELECT view_ordering
            FROM public.recent_view
            WHERE
                user_id = (
                    SELECT user_id
                    FROM public.user
                    WHERE
                        username = 'test_user'
                )
                AND type_id = 'tt18339924'
        ) >= 3, 'Recent view test'
    );

-- test whatchlist movie
INSERT INTO
    public.user_movie_whatchlist ("user_id", movie_id)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        'tt18339924'
    );

INSERT INTO
    public.user_movie_whatchlist ("user_id", movie_id)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        'tt21217874'
    );

SELECT pgtap.ok (
        (
            SELECT whatchlist
            FROM public.user_movie_whatchlist
            WHERE
                user_id = (
                    SELECT user_id
                    FROM public.user
                    WHERE
                        username = 'test_user'
                )
                AND movie_id = 'tt21217874'
        ) >= 2, 'movie Whatchlist test'
    );

-- test whatchlist series

INSERT INTO
    public.user_series_whatchlist ("user_id", series_id)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        'tt0903747'
    );

INSERT INTO
    public.user_series_whatchlist ("user_id", series_id)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        'tt28638980'
    );

-- should be higer then select movie_whatchlist
SELECT pgtap.ok (
        (
            SELECT whatchlist
            FROM public.user_series_whatchlist
            WHERE
                user_id = (
                    SELECT user_id
                    FROM public.user
                    WHERE
                        username = 'test_user'
                )
                AND series_id = 'tt28638980'
        ) >= 4, 'series Whatchlist test'
    );

-- test whatchlist episode

INSERT INTO
    public.user_episode_whatchlist ("user_id", episode_id)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        'tt11437568'
    );

INSERT INTO
    public.user_episode_whatchlist ("user_id", episode_id)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        'tt11576414'
    );

-- should be higher then select series_whatchlist

SELECT pgtap.ok (
        (
            SELECT whatchlist
            FROM public.user_episode_whatchlist
            WHERE
                user_id = (
                    SELECT user_id
                    FROM public.user
                    WHERE
                        username = 'test_user'
                )
                AND episode_id = 'tt11576414'
        ) >= 6, 'episode Whatchlist test'
    );

-- test rating movie/series/episode

INSERT INTO
    public.user_movie_rating ("user_id", movie_id, rating)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        'tt18339924',
        5
    );

INSERT INTO
    public.user_series_rating ("user_id", series_id, rating)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        'tt0903747',
        5
    );

INSERT INTO
    public.user_episode_rating ("user_id", episode_id, rating)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        'tt11437568',
        5
    );

-- should be 5
SELECT pgtap.ok (
        (
            SELECT rating
            FROM public.user_movie_rating
            WHERE
                user_id = (
                    SELECT user_id
                    FROM public.user
                    WHERE
                        username = 'test_user'
                )
                AND movie_id = 'tt18339924'
        ) >= 5, 'movie rating test'
    );

------------- delete user test ------------------------------

DELETE FROM public."user" WHERE username = 'test_user';

DELETE FROM public."user" WHERE username = 'test_user2';

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public."user"
        ) = 0, 'User deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.recent_view
        ) = 0, 'Recent view deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_movie_whatchlist
        ) = 0, 'movie whatchlist deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_series_whatchlist
        ) = 0, 'series whatchlist deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_episode_whatchlist
        ) = 0, 'episode whatchlist deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_movie_rating
        ) = 0, 'movie rating deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_series_rating
        ) = 0, 'series rating deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_episode_rating
        ) = 0, 'episode rating deleted'
    );
------------------------------------------------------------------------------------------
--multi user test
------------------------------------------------------------------------------------------
DO $$
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO public."user" (username, "password", salt, email)
        VALUES (
            'user' || i,
            sha256(('user' || i)::bytea),
            sha256(('user' || i || '@example.com')::bytea),
            'user' || i || '@example.com'
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
BEGIN
    -- Get movie_ids, series_ids, episode_ids, and type_ids
    SELECT array_agg(movie_id) INTO movie_ids FROM public.movie;
    SELECT array_agg(series_id) INTO series_ids FROM public.series;
    SELECT array_agg(episode_id) INTO episode_ids FROM public.episode;
    SELECT array_agg("type_id" ORDER BY random()) INTO type_ids FROM public.type;

    FOR i IN 1..100 LOOP
        new_user_id := (SELECT "user_id" FROM public."user" WHERE username = 'user' || i);

        -- Insert 10 user_movie_whatchlist
        FOR j IN 1..100 LOOP
            INSERT INTO public.user_movie_whatchlist("user_id", movie_id) 
            VALUES (
                new_user_id,
                movie_ids[(i+j)::int]
            ) ON CONFLICT ("user_id", movie_id) DO UPDATE SET
                "user_id" = new_user_id,
                movie_id = movie_ids[(i+j)::int];
        END LOOP;

        -- Insert 10 user_series_whatchlist
        FOR j IN 1..100 LOOP
            INSERT INTO public.user_series_whatchlist("user_id", series_id)
            VALUES (
                new_user_id,
                series_ids[( i + j)::int]
            ) ON CONFLICT ("user_id", series_id) DO UPDATE SET
                "user_id" = new_user_id,
                series_id = series_ids[(i+j)::int];
        END LOOP;

        -- Insert 10 user_episode_whatchlist
        FOR j IN 1..100 LOOP
            INSERT INTO public.user_episode_whatchlist("user_id", episode_id)
             VALUES (
                new_user_id,
                episode_ids[(i+j)::int]
            ) ON CONFLICT ("user_id", episode_id) DO UPDATE SET
                "user_id" = new_user_id,
                episode_id = episode_ids[(i+j)::int];
        END LOOP;

        -- Insert 10 recent_views
        FOR j IN 1..100 LOOP
            random_int := floor(random() * (10 * i + j ) + 1)::int;
            INSERT INTO public.recent_view ("user_id", "type_id")
            VALUES (
                new_user_id,
                type_ids[random_int]
            ) ON CONFLICT ("user_id", "type_id") DO UPDATE SET
                "user_id" = new_user_id,
                "type_id" = type_ids[random_int];
        END LOOP;

        FOR j IN 1..100 LOOP
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

        FOR j IN 1..100 LOOP
            random_int := floor(random() * (10) + 1)::int;
            INSERT INTO public.user_series_rating ("user_id", series_id, rating)
            VALUES (
                new_user_id,
                series_ids[(i+j)::int],
                random_int
            ) ON CONFLICT ("user_id", series_id) DO UPDATE SET
                "user_id" = new_user_id,
                series_id = series_ids[(i+j)::int],
                rating = random_int;
        END LOOP;

        FOR j IN 1..100 LOOP
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

----test duymmy users----

SELECT pgtap.ok (
        (
            SELECT COUNT(*)
            FROM public."user"
        ) = 100, '100 users created'
    );

SELECT pgtap.ok (
        (
            SELECT COUNT(*)
            FROM public.movie
            WHERE
                popularity > 0
        ) >= 10, 'popularity populated movie test'
    );

SELECT pgtap.is (
        (
            SELECT count(*)
            FROM public.user_movie_whatchlist
            GROUP BY
                "user_id", movie_id, whatchlist
            HAVING
                count(*) > 1
        ), NULL, 'No duplicate entries in user_movie_interaction'
    );

SELECT pgtap.is (
        (
            SELECT count(*)
            FROM public.user_series_whatchlist
            GROUP BY
                "user_id", series_id, whatchlist
            HAVING
                count(*) > 1
        ), NULL, 'No duplicate entries in user_series_interaction'
    );

SELECT pgtap.is (
        (
            SELECT count(*)
            FROM public.user_episode_whatchlist
            GROUP BY
                "user_id", episode_id, whatchlist
            HAVING
                count(*) > 1
        ), NULL, 'No duplicate entries in user_episode_interaction'
    );

SELECT pgtap.is (
        (
            SELECT count(*)
            FROM public.recent_view
            GROUP BY
                "user_id", "type_id", view_ordering
            HAVING
                count(*) > 1
        ), NULL, 'No duplicate entries in recent_view'
    );

SELECT pgtap.is (
        (
            SELECT count(*)
            FROM public.user_movie_rating
            GROUP BY
                "user_id", movie_id, rating
            HAVING
                count(*) > 1
        ), NULL, 'No duplicate entries in user_movie_rating'
    );

SELECT pgtap.is (
        (
            SELECT count(*)
            FROM public.user_series_rating
            GROUP BY
                "user_id", series_id, rating
            HAVING
                count(*) > 1
        ), NULL, 'No duplicate entries in user_series_rating'
    );

SELECT pgtap.is (
        (
            SELECT count(*)
            FROM public.user_episode_rating
            GROUP BY
                "user_id", episode_id, rating
            HAVING
                count(*) > 1
        ), NULL, 'No duplicate entries in user_episode_rating'
    );

-- test type trigger --------------------------------------------
INSERT INTO
    public.movie (
        title,
        re_year,
        run_time,
        poster,
        plot,
        release_date,
        imdb_rating
    )
VALUES (
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
            FROM public."type"
            WHERE
                "type_id" IN (
                    SELECT movie_id
                    FROM public.movie
                    WHERE
                        title = 'The Revenant'
                )
            LIMIT 1
        ), 'movie', 'Movie type trigger'
    );

INSERT INTO
    public.series (
        title,
        start_year,
        end_year,
        poster,
        plot,
        imdb_rating
    )
VALUES (
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
                "type_id" = (
                    SELECT series_id
                    FROM public.series
                    WHERE
                        title = 'Stranger Things'
                )
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
        title,
        re_year,
        run_time,
        plot,
        relese_date,
        imdb_rating
    )
VALUES (
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
                "type_id" = (
                    SELECT episode_id
                    FROM public.episode
                    WHERE
                        title = 'Chapter One: The Vanishing of Will Byers'
                )
        ), 'episode', 'Episode type trigger'
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
DELETE FROM public.movie
WHERE
    movie_id IN (
        SELECT movie_id
        FROM public.movie
        WHERE
            title = 'The Revenant'
        LIMIT 1
    );

DELETE FROM public.series
WHERE
    series_id = (
        SELECT series_id
        FROM public.series
        WHERE
            title = 'Stranger Things'
    );

DELETE FROM public.episode
WHERE
    episode_id = (
        SELECT episode_id
        FROM public.episode
        WHERE
            title = 'Chapter One: The Vanishing of Will Byers'
    );

DELETE FROM public."user" WHERE username LIKE 'user%';

SELECT * FROM pgtap.finish ();

END;