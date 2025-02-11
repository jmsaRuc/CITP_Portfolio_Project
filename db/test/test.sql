--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Data base test
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

SET search_path TO public, pgtap, fuzzy;

BEGIN;

SELECT pgtap.plan (77);

----clean up posibel dummmy users befor

DELETE FROM public."user" WHERE username LIKE 'user%';

--------------------------------------------------------------------------------
-- test genre functions
--------------------------------------------------------------------------------
SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.get_all_genres ()
        ) >= 32, 'get_all_genres'
    );

SELECT pgtap.ok (
        (
            SELECT total_amount
            FROM public.get_genre ('Action')
        ) >= 10000, 'get_genre'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)::int
            FROM public.get_genre_episodes ('Action')
        ) = (
            SELECT episode_amount
            FROM public.get_genre ('Action')
        ), 'get_genre_episodes'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)::int
            FROM public.get_genre_movies ('Action')
        ) = (
            SELECT movie_amount
            FROM public.get_genre ('Action')
        ), 'get_genre_movies'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)::int
            FROM public.get_genre_series ('Action')
        ) = (
            SELECT series_amount
            FROM public.get_genre ('Action')
        ), 'get_genre_series'
    );

SELECT pgtap.is (
        (
            SELECT genre_name_of
            FROM public.get_movie_genres ('tt0936501')
            LIMIT 1
        ), (
            SELECT genre_name_of
            FROM public.get_all_genres ()
            LIMIT 1
        ), 'get_movie_genres'
    );

SELECT pgtap.is (
        (
            SELECT genre_name_of
            FROM public.get_series_genres ('tt11247158')
            LIMIT 1
        ), (
            SELECT genre_name_of
            FROM public.get_all_genres ()
            LIMIT 1
        ), 'get_series_genres'
    );

SELECT pgtap.is (
        (
            SELECT genre_name_of
            FROM public.get_episode_genres ('tt11753166')
            LIMIT 1
        ), (
            SELECT genre_name_of
            FROM public.get_all_genres ()
            LIMIT 1
        ), 'get_episode_genres'
    );
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

----- insert dummy movie
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
        'The Rev',
        2015,
        '156 m',
        'https://m.media-amazon.com/images/I/71r8ZLZqjwL._AC_SY679_.jpg',
        'A frontiersman on a fur trading expedition in the 1820s fights for survival after being mauled by a bear and left for dead by members of his own hunting team.',
        '2016-01-08',
        8.0
    );

----- insert dummy series that is not breaking bad
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
        'Test Series',
        2021,
        NULL,
        'https://example.com/test_series_poster.jpg',
        'A test series for unit testing.',
        7.5
    );

-- test recent view
INSERT INTO
    public.recent_view ("user_id", "type_id")
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        (
            SELECT movie_id
            FROM public.movie
            WHERE
                title = 'The Rev'
        )
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
        (
            SELECT series_id
            FROM public.series
            WHERE
                title = 'Test Series'
        )
    );

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
                AND type_id = (
                    SELECT movie_id
                    FROM public.movie
                    WHERE
                        title = 'The Rev'
                )
        ) > 0, 'Recent view test'
    );

---- test recent trigger ------------------

SELECT pgtap.ok (
        (
            SELECT popularity
            FROM public.movie
            WHERE
                movie_id = (
                    SELECT movie_id
                    FROM public.movie
                    WHERE
                        title = 'The Rev'
                )
        ) >= 1, 'popularity populated movie test'
    );

SELECT pgtap.ok (
        (
            SELECT popularity
            FROM public.series
            WHERE
                series_id = (
                    SELECT series_id
                    FROM public.series
                    WHERE
                        title = 'Test Series'
                )
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
                AND type_id = (
                    SELECT movie_id
                    FROM public.movie
                    WHERE
                        title = 'The Rev'
                )
        ), NULL, 'User deleted'
    );

SELECT pgtap.ok (
        (
            SELECT popularity
            FROM public.movie
            WHERE
                movie_id = (
                    SELECT movie_id
                    FROM public.movie
                    WHERE
                        title = 'The Rev'
                )
        ) = 0, 'popularity delet movie test'
    );

SELECT pgtap.ok (
        (
            SELECT popularity
            FROM public.series
            WHERE
                series_id = (
                    SELECT series_id
                    FROM public.series
                    WHERE
                        title = 'Test Series'
                )
        ) = 0, 'popularity delet series test'
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
        (
            SELECT movie_id
            FROM public.movie
            WHERE
                title = 'The Rev'
        )
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
                AND type_id = (
                    SELECT movie_id
                    FROM public.movie
                    WHERE
                        title = 'The Rev'
                )
        ) >= 3, 'Recent view test'
    );

-- test watchlist movie
INSERT INTO
    public.user_movie_watchlist ("user_id", movie_id)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        (
            SELECT movie_id
            FROM public.movie
            WHERE
                title = 'The Rev'
        )
    );

INSERT INTO
    public.user_movie_watchlist ("user_id", movie_id)
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
            SELECT watchlist
            FROM public.user_movie_watchlist
            WHERE
                user_id = (
                    SELECT user_id
                    FROM public.user
                    WHERE
                        username = 'test_user'
                )
                AND movie_id = 'tt21217874'
        ) >= 2, 'movie watchlist test'
    );

-- test watchlist series

INSERT INTO
    public.user_series_watchlist ("user_id", series_id)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        (
            SELECT series_id
            FROM public.series
            WHERE
                title = 'Test Series'
        )
    );

INSERT INTO
    public.user_series_watchlist ("user_id", series_id)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        'tt28638980'
    );

-- should be higer then select movie_watchlist
SELECT pgtap.ok (
        (
            SELECT watchlist
            FROM public.user_series_watchlist
            WHERE
                user_id = (
                    SELECT user_id
                    FROM public.user
                    WHERE
                        username = 'test_user'
                )
                AND series_id = 'tt28638980'
        ) >= 4, 'series watchlist test'
    );

-- test watchlist episode

INSERT INTO
    public.user_episode_watchlist ("user_id", episode_id)
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
    public.user_episode_watchlist ("user_id", episode_id)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        'tt11576414'
    );

-- should be higher then select series_watchlist

SELECT pgtap.ok (
        (
            SELECT watchlist
            FROM public.user_episode_watchlist
            WHERE
                user_id = (
                    SELECT user_id
                    FROM public.user
                    WHERE
                        username = 'test_user'
                )
                AND episode_id = 'tt11576414'
        ) >= 6, 'episode watchlist test'
    );

-------------------------- test rating movie/series/episode

INSERT INTO
    public.user_movie_rating ("user_id", movie_id, rating)
VALUES (
        (
            SELECT user_id
            FROM public.user
            WHERE
                username = 'test_user'
        ),
        (
            SELECT movie_id
            FROM public.movie
            WHERE
                title = 'The Rev'
        ),
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
        (
            SELECT series_id
            FROM public.series
            WHERE
                title = 'Test Series'
        ),
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
                AND movie_id = (
                    SELECT movie_id
                    FROM public.movie
                    WHERE
                        title = 'The Rev'
                )
        ) = 5, 'movie rating test'
    );

---------------test rating update trigger ----------------------------

UPDATE public.user_movie_rating
SET
    rating = 3
WHERE
    user_id = (
        SELECT user_id
        FROM public.user
        WHERE
            username = 'test_user'
    )
    AND movie_id = (
        SELECT movie_id
        FROM public.movie
        WHERE
            title = 'The Rev'
    );

SELECT pgtap.ok (
        (
            SELECT average_rating
            FROM public.movie
            WHERE
                movie_id = (
                    SELECT movie_id
                    FROM public.movie
                    WHERE
                        title = 'The Rev'
                )
        ) = 3, 'rating update trigger'
    );

--------------------------------------- delete user test -----------------------------------------

DELETE FROM public."user" WHERE username = 'test_user';

DELETE FROM public."user" WHERE username = 'test_user2';

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public."user"
            WHERE
                username LIKE 'user%'
        ) = 0, 'User deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.recent_view
            WHERE
                "user_id" IN (
                    SELECT "user_id"
                    FROM public."user"
                    WHERE
                        username LIKE 'user%'
                )
        ) = 0, 'Recent view deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_movie_watchlist
            WHERE
                "user_id" IN (
                    SELECT "user_id"
                    FROM public."user"
                    WHERE
                        username LIKE 'user%'
                )
        ) = 0, 'movie watchlist deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_series_watchlist
            WHERE
                "user_id" IN (
                    SELECT "user_id"
                    FROM public."user"
                    WHERE
                        username LIKE 'user%'
                )
        ) = 0, 'series watchlist deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_episode_watchlist
            WHERE
                "user_id" IN (
                    SELECT "user_id"
                    FROM public."user"
                    WHERE
                        username LIKE 'user%'
                )
        ) = 0, 'episode watchlist deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_movie_rating
            WHERE
                "user_id" IN (
                    SELECT "user_id"
                    FROM public."user"
                    WHERE
                        username LIKE 'user%'
                )
        ) = 0, 'movie rating deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_series_rating
            WHERE
                "user_id" IN (
                    SELECT "user_id"
                    FROM public."user"
                    WHERE
                        username LIKE 'user%'
                )
        ) = 0, 'series rating deleted'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.user_episode_rating
            WHERE
                "user_id" IN (
                    SELECT "user_id"
                    FROM public."user"
                    WHERE
                        username LIKE 'user%'
                )
        ) = 0, 'episode rating deleted'
    );
------------------------rating delet trigger test --------------------------------------------
SELECT pgtap.ok (
        (
            SELECT average_rating
            FROM public.movie
            WHERE
                movie_id = (
                    SELECT movie_id
                    FROM public.movie
                    WHERE
                        title = 'The Rev'
                )
        ) = 0.0, 'movie rating delet trigger '
    );

SELECT pgtap.ok (
        (
            SELECT average_rating
            FROM public.series
            WHERE
                series_id = (
                    SELECT series_id
                    FROM public.series
                    WHERE
                        title = 'Test Series'
                )
        ) = 0.0, 'series rating delet trigger '
    );
SELECT pgtap.ok (
        (
            SELECT average_rating
            FROM public.episode
            WHERE
                episode_id = 'tt11437568'
        ) < 5, 'episode rating delet trigger '
    );

--- clean up
DELETE FROM public.movie WHERE title = 'The Rev';

DELETE FROM public.series WHERE title = 'Test Series';



------------------------------------------------------------------------------------------
-- test person functions
------------------------------------------------------------------------------------------

--------------------------------------------get_top_actors------------------------------------------------------------
SELECT pgtap.is (
        (
            SELECT person_id
            FROM public.is_in_movie
            WHERE
                movie_id = 'tt1596363'
                AND (
                    "role" = 'actor'
                    OR "role" = 'actress'
                )
            ORDER BY cast_order ASC
            LIMIT 1
        ), (
            SELECT person_id_v
            FROM public.get_top_actors_in_movie ('tt1596363')
            LIMIT 1
        ), 'get_top_actors_in_movie'
    );

SELECT pgtap.is (
        (
            SELECT person_id
            FROM public.is_in_series
            WHERE
                series_id = 'tt20877972'
                AND (
                    "role" = 'actor'
                    OR "role" = 'actress'
                )
            ORDER BY cast_order ASC
            LIMIT 1
        ), (
            SELECT person_id_v
            FROM public.get_top_actors_in_series ('tt20877972')
            LIMIT 1
        ), 'get_top_actors_in_series'
    );

SELECT pgtap.is (
        (
            SELECT person_id
            FROM public.is_in_episode
            WHERE
                episode_id = 'tt0959621'
                AND (
                    "role" = 'actor'
                    OR "role" = 'actress'
                )
            ORDER BY cast_order ASC
            LIMIT 1
        ), (
            SELECT person_id_v
            FROM public.get_top_actors_in_episode ('tt0959621')
            LIMIT 1
        ), 'get_top_actors_in_episode'
    );

-----------get writers in movie/series/episode-----------------------------------
SELECT pgtap.is (
        (
            SELECT person_id
            FROM public.is_in_movie
            WHERE
                movie_id = 'tt1596363'
                AND (
                    "role" = 'writer'
                    OR job = 'writen by'
                )
            ORDER BY cast_order ASC
            LIMIT 1
        ), (
            SELECT person_id_v
            FROM public.get_writers_in_movie ('tt1596363')
            LIMIT 1
        ), 'get_writers_in_movie'
    );

SELECT pgtap.is (
        (
            SELECT person_id
            FROM public.is_in_series
            WHERE
                series_id = 'tt20877972'
                AND (
                    "role" = 'writer'
                    OR job = 'writen by'
                )
            ORDER BY cast_order ASC
            LIMIT 1
        ), (
            SELECT person_id_v
            FROM public.get_writers_in_series ('tt20877972')
            LIMIT 1
        ), 'get_writers_in_series'
    );

SELECT pgtap.is (
        (
            SELECT person_id
            FROM public.is_in_episode
            WHERE
                episode_id = 'tt0959621'
                AND (
                    "role" = 'writer'
                    OR job = 'writen by'
                )
            ORDER BY cast_order ASC
            LIMIT 1
        ), (
            SELECT person_id_v
            FROM public.get_writers_in_episode ('tt0959621')
            LIMIT 1
        ), 'get_writers_in_episode'
    );
--------------------------get director and creator in movie/series/episode-----------------------------------
SELECT pgtap.is (
        (
            SELECT person_id
            FROM public.is_in_movie
            WHERE
                movie_id = 'tt1596363'
                AND (
                    "role" = 'director'
                    OR job = 'directed by'
                )
            ORDER BY cast_order ASC
            LIMIT 1
        ), (
            SELECT person_id_v
            FROM public.get_director_in_movie ('tt1596363')
        ), 'get_directors_in_movie'
    );

SELECT pgtap.is (
        (
            SELECT person_id
            FROM public.is_in_series
            WHERE
                series_id = 'tt20877972'
                AND (
                    "role" = 'writer'
                    AND job = 'created by'
                )
            ORDER BY cast_order ASC
            LIMIT 1
        ), (
            SELECT person_id_v
            FROM public.get_creator_in_series ('tt20877972')
        ), 'get_directors_in_series'
    );

SELECT pgtap.is (
        (
            SELECT person_id
            FROM public.is_in_episode
            WHERE
                episode_id = 'tt0959621'
                AND (
                    "role" = 'director'
                    OR job = 'directed by'
                )
            ORDER BY cast_order ASC
            LIMIT 1
        ), (
            SELECT person_id_v
            FROM public.get_director_in_episode ('tt0959621')
        ), 'get_directors_in_episode'
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
            INSERT INTO public.user_series_watchlist("user_id", series_id)
            VALUES (
                new_user_id,
                series_ids[( i + j)::int]
            ) ON CONFLICT ("user_id", series_id) DO UPDATE SET
                "user_id" = new_user_id,
                series_id = series_ids[(i+j)::int];
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
            random_int := floor(random() * (10 * i + j ) + 1)::int;
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

----test duymmy users----

SELECT pgtap.ok (
        (
            SELECT COUNT(*)
            FROM public."user"
            WHERE
                username LIKE 'user%'
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
            FROM public.user_movie_watchlist
            GROUP BY
                "user_id", movie_id, watchlist
            HAVING
                count(*) > 1
        ), NULL, 'No duplicate entries in user_movie_interaction'
    );

SELECT pgtap.is (
        (
            SELECT count(*)
            FROM public.user_series_watchlist
            GROUP BY
                "user_id", series_id, watchlist
            HAVING
                count(*) > 1
        ), NULL, 'No duplicate entries in user_series_interaction'
    );

SELECT pgtap.is (
        (
            SELECT count(*)
            FROM public.user_episode_watchlist
            GROUP BY
                "user_id", episode_id, watchlist
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

----test search triggers ----------------------------------------------------------------------------------

--movie search trigger
SELECT pgtap.is (
        (
            SELECT movie_id
            FROM public.movie
            ORDER BY popularity DESC
            LIMIT 1
        ), (
            SELECT movie_id
            FROM public.movie_search
            ORDER BY popularity DESC
            LIMIT 1
        ), 'search_movie trigger'
    );

-- series search trigger

SELECT pgtap.is (
        (
            SELECT series_id
            FROM public.series
            ORDER BY popularity DESC
            LIMIT 1
        ), (
            SELECT series_id
            FROM public.series_search
            ORDER BY popularity DESC
            LIMIT 1
        ), 'search_series trigger'
    );

-- episode search trigger

SELECT pgtap.is (
        (
            SELECT episode_id
            FROM public.episode
            ORDER BY popularity DESC
            LIMIT 1
        ), (
            SELECT episode_id
            FROM public.episode_search
            ORDER BY popularity DESC
            LIMIT 1
        ), 'search_episode trigger'
    );

-- person search trigge

SELECT pgtap.is (
        (
            SELECT person_id
            FROM public.person
            ORDER BY popularity DESC
            LIMIT 1
        ), (
            SELECT person_id
            FROM public.person_search
            ORDER BY popularity DESC
            LIMIT 1
        ), 'search_person trigger'
    );

------------------------------------------test search functions -----------------------------------
SELECT pgtap.is (
        (
            SELECT title_v
            FROM public.search_movie_quick (
                    'the big short', (
                        SELECT "user_id"
                        FROM public."user"
                        LIMIT 1
                    )
                )
            LIMIT 1
        ), (
            SELECT title
            FROM public.movie
            WHERE
                title = 'The Big Short'
        ), 'search_movie_quick'
    );

SELECT pgtap.is (
        (
            SELECT title_v
            FROM public.search_series_quick (
                    'breaking bad', (
                        SELECT "user_id"
                        FROM public."user"
                        LIMIT 1
                    )
                )
            LIMIT 1
        ), (
            SELECT title
            FROM public.series
            WHERE
                title = 'Breaking Bad'
        ), 'search_series_quick'
    );

SELECT pgtap.is (
        (
            SELECT title_v
            FROM public.search_episode_quick (
                    'battle of the bastards', (
                        SELECT "user_id"
                        FROM public."user"
                        LIMIT 1
                    )
                )
            LIMIT 1
        ), (
            SELECT title
            FROM public.episode
            WHERE
                title = 'Battle of the Bastards'
        ), 'search_episode_quick'
    );

SELECT pgtap.is (
        (
            SELECT name_v
            FROM public.search_person_quick (
                    'Ryan Gosling', (
                        SELECT "user_id"
                        FROM public."user"
                        LIMIT 1
                    )
                )
            LIMIT 1
        ), (
            SELECT "name"
            FROM public.person
            WHERE
                "name" = 'Ryan Gosling'
        ), 'search_person_quick'
    );
---------------test search slow -----------------------------------

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.search_movie_slow ('the byg shart')
            LIMIT 1
        ) > 0, 'search_movie_slow'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.search_series_slow ('brakidg byd')
            LIMIT 1
        ) > 0, 'search_series_slow'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.search_episode_slow ('battel of the nastards')
            LIMIT 1
        ) > 0, 'search_episode_slow'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.search_person_slow ('ryan gyslong')
            LIMIT 1
        ) > 0, 'search_person_slow'
    );
-----test all searsh

SELECT pgtap.is (
        (
            SELECT title_s
            FROM public.search_all (
                    'the big short', (
                        SELECT "user_id"
                        FROM public."user"
                        LIMIT 1
                    )
                )
            LIMIT 1
        ), (
            SELECT title
            FROM public.movie
            WHERE
                title = 'The Big Short'
        ), 'search_all'
    );

-- test get series episodes -----------------------------------
SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.get_episodes_in_series ('tt094494', 0)
        ) = (
            SELECT count(*)
            FROM public.episode_series
            WHERE
                series_id = 'tt094494'
        ), 'get_series_episodes'
    );

SELECT pgtap.ok (
        (
            SELECT count(*)
            FROM public.get_episodes_in_series ('tt094494', 1)
        ) = (
            SELECT count(*)
            FROM public.episode_series
            WHERE
                series_id = 'tt094494'
                AND season_number = 1
        ), 'get_series_episodes'
    );


----test get person credit ----------------------------------- 
SELECT pgtap.is (
        (
            SELECT title_v
            FROM public.get_person_credit('nm0000138')
            WHERE
                title_v= 'Inception'
        ), 
        (
            SELECT title
            FROM public.movie NATURAL JOIN is_in_movie
            WHERE
                person_id = 'nm0000138' and movie_id = 'tt1375666'
        ), 'get_person_credit'
    );

-- test get user watchlist-----------------------------------

SELECT pgtap.is (
        (
            SELECT max(watchlist)
            FROM public.user_movie_watchlist
            WHERE
                "user_id" = (
                    SELECT "user_id"
                    FROM public."user"
                    LIMIT 1
                )
        ), (
            SELECT max(watchlist_order)
            FROM public.get_user_watchlist (
                    (
                        SELECT "user_id"
                        FROM public."user"
                        LIMIT 1
                    )
                )
            WHERE
                title_type = 'movie'
        ), 'get_user_watchlist'
    );
--- test get user rating -----------------------------------
SELECT pgtap.is (
        (
            SELECT movie_id
            FROM public.user_movie_rating
            WHERE
                "user_id" = (
                    SELECT "user_id"
                    FROM public."user"
                    LIMIT 1
                )
            ORDER BY movie_id DESC
            LIMIT 1
        ), (
            SELECT title_id
            FROM public.get_user_rating (
                    (
                        SELECT "user_id"
                        FROM public."user"
                        LIMIT 1
                    )
                )
            WHERE
                title_type = 'movie'
            ORDER BY title_id DESC
            LIMIT 1
        ), 'get_user_rating'
    );
-----------------------test get user recent view -----------------------------------
SELECT pgtap.is (
        (
            SELECT "type_id"
            FROM public.recent_view
            WHERE
                "user_id" = (
                    SELECT "user_id"
                    FROM public."user"
                    LIMIT 1
                )
            GROUP BY
                "type_id"
            ORDER BY max(view_ordering) DESC
            LIMIT 1
        ), (
            SELECT "type_id_of"
            FROM public.get_user_recent_view (
                    (
                        SELECT "user_id"
                        FROM public."user"
                        LIMIT 1
                    )
                )
            ORDER BY view_order DESC
            LIMIT 1
        ), 'get_user_recent_view'
    );
--------------------------------------------test top week (materualized_views) -----------------------------------
REFRESH MATERIALIZED VIEW CONCURRENTLY public.top_this_week;

SELECT pgtap.ok (
        (
            SELECT popularity
            FROM public.top_this_week
            ORDER BY popularity ASC
            LIMIT 1
        ) >= 1, 'top_this_week'
    );
-----------------------------------test rating insert triggers when meny --------------------------------------------
SELECT pgtap.is (
        (
            SELECT movie_id
            FROM public.user_movie_rating
            WHERE
                "user_id" = (
                    SELECT "user_id"
                    FROM public."user"
                    LIMIT 1
                )
            GROUP BY
                movie_id
            ORDER BY max(rating) DESC
            LIMIT 1
        ), (
            SELECT movie_id
            FROM public."movie"
            WHERE
                "movie_id" = (
                    SELECT movie_id
                    FROM public.user_movie_rating
                    WHERE
                        "user_id" = (
                            SELECT "user_id"
                            FROM public."user"
                            LIMIT 1
                        )
                    GROUP BY
                        movie_id
                    ORDER BY max(rating) DESC
                    LIMIT 1
                )
            GROUP BY
                movie_id
            ORDER BY max(average_rating) DESC
        ), 'movie rating trigger'
    );

SELECT pgtap.is (
        (
            SELECT series_id
            FROM public.user_series_rating
            WHERE
                "user_id" = (
                    SELECT "user_id"
                    FROM public."user"
                    LIMIT 1
                )
            GROUP BY
                series_id
            ORDER BY max(rating) DESC
            LIMIT 1
        ), (
            SELECT series_id
            FROM public."series"
            WHERE
                "series_id" = (
                    SELECT series_id
                    FROM public.user_series_rating
                    WHERE
                        "user_id" = (
                            SELECT "user_id"
                            FROM public."user"
                            LIMIT 1
                        )
                    GROUP BY
                        series_id
                    ORDER BY max(rating) DESC
                    LIMIT 1
                )
            GROUP BY
                series_id
            ORDER BY max(average_rating) DESC
        ), 'series rating trigger'
    );

SELECT pgtap.is (
        (
            SELECT episode_id
            FROM public.user_episode_rating
            WHERE
                "user_id" = (
                    SELECT "user_id"
                    FROM public."user"
                    LIMIT 1
                )
            GROUP BY
                episode_id
            ORDER BY max(rating) DESC
            LIMIT 1
        ), (
            SELECT episode_id
            FROM public."episode"
            WHERE
                "episode_id" = (
                    SELECT episode_id
                    FROM public.user_episode_rating
                    WHERE
                        "user_id" = (
                            SELECT "user_id"
                            FROM public."user"
                            LIMIT 1
                        )
                    GROUP BY
                        episode_id
                    ORDER BY max(rating) DESC
                    LIMIT 1
                )
            GROUP BY
                episode_id
            ORDER BY max(average_rating) DESC
        ), 'episode rating trigger'
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
        poster,
        plot,
        relese_date,
        imdb_rating
    )
VALUES (
        'Chapter One: The Vanishing of Will Byers',
        2016,
        '48 m',
        'https://m.media-amazon.com/images/M/MV5BMTUwNTE0ODYzOF5BMl5BanBnXkFtZTgwOTc0ODE0OTE@._V1_FMjpg_UX480_.jpg',
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
        LIMIT 1    
    );

DELETE FROM public.episode
WHERE
    episode_id = (
        SELECT episode_id
        FROM public.episode
        WHERE
            title = 'Chapter One: The Vanishing of Will Byers'
        LIMIT 1  
                );

REFRESH MATERIALIZED VIEW public.top_this_week;

DELETE FROM public."user" WHERE username LIKE 'user%';

SELECT * FROM pgtap.finish ();

END;