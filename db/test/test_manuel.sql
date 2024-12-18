SET search_path TO public, pgtap, fuzzy;

ALTER ROLE "admin" SET search_path=public, pgtap, fuzzy;
------- misc test queries -------
SELECT *
FROM public.get_person_credit('nm0000138');

SELECT max(watchlist)
            FROM public.user_movie_watchlist
            GROUP BY "user_id"
            LIMIT 1;

SELECT max(watchlist_order)
            FROM public.get_user_watchlist (
                    (
                        SELECT public."user_id"
                        FROM public."user"
                        LIMIT 1
                    )
                )
            WHERE
                title_type = 'movie'

SELECT *
FROM public.search_all('Guardians of ', 'ur00002071' )
    
SELECT *
FROM public.episode_series
WHERE series_id = 'tt0944947'

SELECT title, release_date
FROM public.movie
WHERE release_date IS NOT NULL

            SELECT *
            FROM public.get_person_credit('nm0000138');

            SELECT title
            FROM public.movie NATURAL JOIN is_in_movie
            WHERE
                person_id = 'nm0000138' and movie_id = 'tt1375666'

            SELECT *
            FROM public.search_movie_quick('the big short', (SELECT "user_id" FROM public."user" LIMIT 1))
            LIMIT 1;

            SELECT *
            FROM public.search_series_quick('breaking bad', (SELECT "user_id" FROM public."user" LIMIT 1))
            LIMIT 1;

            SELECT *
            FROM public.search_episode_quick (
                    'battle of the bastards', (
                        SELECT "user_id"
                        FROM public."user"
                        LIMIT 1
                    )
                )
            LIMIT 1;    

                SELECT *
            FROM public.search_person_quick (
                    'Ryan Gosling', (
                        SELECT "user_id"
                        FROM public."user"
                        LIMIT 1
                    )
                )
            LIMIT 1;    


            SELECT *
            FROM public.search_movie_slow ('the big snort');

 

SELECT DISTINCT genre_name
FROM movie_genre;

SELECT DISTINCT genre_name
FROM episode_genre;

SELECT DISTINCT genre_name
FROM series_genre;

SELECT person_id
            FROM public.is_in_series
            WHERE
                series_id = 'tt20877972'
                AND "role" = 'actor'
            ORDER BY cast_order ASC
            LIMIT 1

SELECT *
FROM public.get_top_actors_in_series('tt20877972');

SELECT *
FROM is_in_series
WHERE series_id = 'tt20877972'
ORDER BY cast_order ASC

SELECT *
FROM public.top_this_week


SELECT *
FROM get_top_actors_in_series('tt20877972')
LIMIT 1;

SELECT *
FROM public.episode
WHERE popularity is not NULL and popularity > 0
ORDER BY popularity DESC


SELECT *
FROM public.string_search ('the biG short');

SELECT *
FROM public.episode
WHERE episode_id = 'tt0959621';

SELECT  episode_id , rating
FROM public.user_episode_rating
WHERE "user_id" = (SELECT "user_id" FROM public."user" LIMIT 1)
ORDER BY episode_id DESC
LIMIT 1;

SELECT *
FROM public.get_user_rating((SELECT "user_id" FROM public."user" LIMIT 1))
WHERE title_type = 'episode'
ORDER BY title_id DESC
LIMIT 1;
---------------test get genre function

SELECT *
FROM public.get_all_genres();
SELECT *
FROM public.get_genre('Action');

SELECT *
FROM public.get_genre_episodes('Action');

SELECT *
FROM public.get_genre_movies ('Action')

SELECT *
FROM public.get_genre_series('Action');


--------------test materialized view 
REFRESH MATERIALIZED VIEW public.top_this_week;

--- test if if there is duplicate

SELECT "type_id_v", count(type_id_v)
FROM public.top_this_week
GROUP BY type_id_v
HAVING count(type_id_v) > 1;

SELECT *
FROM public.top_this_week
ORDER BY popularity desc

SELECT *
FROM public.movie
ORDER BY popularity desc

INSERT INTO
    public.recent_view ("user_id", "type_id")
VALUES ('ur00008023', 'tt16383406');

----test get user recent view
SELECT "type_id", max(view_ordering)
FROM public.recent_view
WHERE "user_id" = (SELECT "user_id" FROM public."user" LIMIT 1)
GROUP BY "type_id"
ORDER BY max(view_ordering) DESC
LIMIT 1;

SELECT *
FROM public.get_user_recent_view((SELECT "user_id" FROM public."user" LIMIT 1))
ORDER BY view_order DESC
LIMIT 1;

----test get user rating
SELECT  movie_id, rating
FROM public.user_movie_rating
WHERE "user_id" = (SELECT "user_id" FROM public."user" LIMIT 1)
ORDER BY movie_id DESC
LIMIT 1;

SELECT title_id, user_rating
FROM public.get_user_rating((SELECT "user_id" FROM public."user" LIMIT 1))
WHERE title_type = 'movie'
ORDER BY title_id DESC
LIMIT 1;

-- test rating trigger

SELECT count(*)
            FROM public.search_movie_quick('the big short', (SELECT "user_id" FROM public."user" LIMIT 1))

SELECT *
FROM public.series
WHERE series_id = 'tt11437568'
GROUP BY series_id 
ORDER BY max(average_rating) DESC

-- test get user watchlist

SELECT max(watchlist)
FROM public.user_movie_watchlist
WHERE "user_id" = (SELECT "user_id" FROM public."user" LIMIT 1);

SELECT *
FROM public.get_user_watchlist((SELECT "user_id" FROM public."user" LIMIT 1))
WHERE title_type = 'movie';


INSERT INTO
    public.user (username, password, salt, email)
VALUES ('test_user', sha256('foo'::bytea), sha256('asdw'::bytea), 'wup@gmail.com');

INSERT INTO
    public.user (username, password, salt, email)
VALUES ('test_user2', sha256('foo'::bytea), sha256('asdw'::bytea), 'wup123@gmail.com');


DELETE FROM "user" WHERE username = 'test_user';

INSERT INTO
    public.user (username, password, salt, email)
VALUES ('test_user', sha256('foo'::bytea), sha256('asdw'::bytea), 'wup@gmail.com');

-- shoud be ur00000003
SELECT user_id FROM public."user" WHERE username = 'test_user';


-- should be 2
SELECT view_ordering
FROM public.recent_view
WHERE
    user_id = 'ur00000003'
    AND
    type_id = 'tt26476058';

DELETE FROM public.user WHERE user_id = 'ur00000003';

-- sjould be NUll

SELECT view_ordering
FROM public.recent_view
WHERE
    user_id = 'ur00000003'
    AND
    type_id = 'tt26476058';
    
INSERT INTO
    public.user (username, password, salt, email)
VALUES ('test_user', sha256('foo'::bytea), sha256('asdw'::bytea), 'wup@gmail.com');

INSERT INTO
    public.recent_view ("user_id", "type_id")
VALUES ('ur00000004', 'tt18339924');

-- should be 1 higher then the last one
SELECT view_ordering
FROM public.recent_view
WHERE
    user_id = 'ur00000004'
    AND
    type_id = 'tt18339924';


-- test watchlist movie
INSERT INTO
    public.user_movie_watchlist ("user_id", movie_id)
VALUES ('ur00000004', 'tt18339924');



INSERT INTO
    public.user_movie_watchlist ("user_id", movie_id)
VALUES ('ur00000004', 'tt21217874');


SELECT watchlist
FROM public.user_movie_watchlist
WHERE
    user_id = 'ur00000004'
    AND
    movie_id = 'tt21217874';


-- test watchlist series

INSERT INTO
    public.user_series_watchlist ("user_id", series_id)
VALUES ('ur00000004', 'tt0903747');

INSERT INTO
    public.user_series_watchlist ("user_id", series_id)
VALUES ('ur00000004', 'tt28638980');

-- should be higer then select movie_watchlist
SELECT watchlist
FROM public.user_series_watchlist
WHERE
    user_id = 'ur00000004'
    AND
    series_id = 'tt28638980';


-- test watchlist episode

INSERT INTO
    public.user_episode_watchlist ("user_id", episode_id)
VALUES ('ur00000004', 'tt11437568');

INSERT INTO
    public.user_episode_watchlist ("user_id", episode_id)
VALUES ('ur00000004', 'tt11576414');

-- should be higher then select series_watchlist

SELECT watchlist
FROM public.user_episode_watchlist
WHERE
    user_id = 'ur00000004'
    AND
    episode_id = 'tt11437568';

-- test rating movie/series/episode

INSERT INTO
    public.user_movie_rating ("user_id", movie_id, rating)
VALUES ('ur00000004', 'tt18339924', 5);

INSERT INTO
    public.user_series_rating ("user_id", series_id, rating)
VALUES ('ur00000004', 'tt0903747', 5);

INSERT INTO
    public.user_episode_rating ("user_id", episode_id, rating)
VALUES ('ur00000004', 'tt11437568', 5);

-- should be 5
SELECT rating
FROM public.user_movie_rating
WHERE
    user_id = 'ur00000004'
    AND
    movie_id = 'tt18339924';

-- test recent view trigger

INSERT INTO
    public.recent_view ("user_id", "type_id")
VALUES ('ur00000209', 'tt18339924');

INSERT INTO
    public.recent_view ("user_id", "type_id")
VALUES ('ur00005120', 'tt26476058');

INSERT INTO
    public.recent_view ("user_id", "type_id")
    VALUES ('ur00005120', 'nm0000001');



SELECT * 
FROM public."type"
WHERE "type_id" = 'tt26476058';

SELECT *
FROM public."movie"s
WHERE "movie_id" = 'tt18339924';

SELECT * 
FROM public."series"
WHERE "series_id" = 'tt26476058';

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
END $$ LANGUAGE plpgsql;


SELECT * FROM public.user_episode_watchlist where user_id = 'ur00002833';
-----test duymmy users
SELECT * FROM public.user LIMIT 5;

SELECT * FROM public.user_movie_interaction LIMIT 5;

SELECT * FROM public.user_series_interaction LIMIT 5;

SELECT * FROM public.user_episode_interaction LIMIT 5;

SELECT * FROM public.recent_view LIMIT 5;

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
    );

SELECT title_type FROM type WHERE type_id = 'tt32459823';

SELECT * FROM movie WHERE movie_id = 'tt32459823';

-- test series type trigger

SELECT * FROM public.type WHERE "type_id" = 'tt0903747';

SELECT * FROM series WHERE series_id = 'tt0903747';

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
        'tt4574334',
        'Stranger Things',
        2016,
        NULL,
        'https://m.media-amazon.com/images/I/71r8ZLZqjwL._AC_SY679_.jpg',
        'In 1980s Indiana, a group of young friends witness supernatural forces and secret government exploits. As they search for answers, the children unravel a series of extraordinary mysteries.',
        8.7
    );

SELECT * FROM type WHERE type_id = 'tt4574334';

SELECT * FROM series WHERE series_id = 'tt4574334';

-- test episode type trigger

SELECT * FROM type WHERE type_id = 'tt0959621';

SELECT * FROM episode WHERE episode_id = 'tt0959621';

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
        'tt4593118',
        'Chapter One: The Vanishing of Will Byers',
        2016,
        '48 m',
        'On his way home from a friend''s house, young Will sees something terrifying. Nearby, a sinister secret lurks in the depths of a government lab.',
        '2016-07-15',
        8.4
    );

SELECT * FROM type WHERE type_id = 'tt4593118';

SELECT * FROM episode WHERE episode_id = 'tt4593118';


----------------------test user functionality----------------------
SELECT public.create_user (
        'test_user', sha256('foo'::bytea), 'test_user@gmail.com'
    );

SELECT new_watchlist_movie ('ur00000101', 'tt32459823');

SELECT new_watchlist_movie ('ur00000101', 'tt1596363');

SELECT *
FROM public.user_movie_interaction
WHERE
    user_id = 'ur00000101';

SELECT new_watchlist_series ('ur00000101', 'tt0903747');

SELECT new_watchlist_series ('ur00000101', 'tt4574334');

SELECT *
FROM public.user_series_interaction
WHERE
    user_id = 'ur00000101';

SELECT new_watchlist_episode ('ur00000101', 'tt0959621');

SELECT new_watchlist_episode ('ur00000101', 'tt4593118');

SELECT *
FROM public.user_episode_interaction
WHERE
    user_id = 'ur00000101'

DELETE FROM "user" WHERE user_id = 'ur00000101';

SELECT *
FROM public.user_movie_interaction
WHERE
    user_id = 'ur00000101';

SELECT *
FROM public.user_series_interaction
WHERE
    user_id = 'ur00000101';

SELECT *
FROM public.user_episode_interaction
WHERE
    user_id = 'ur00000101';

SELECT * FROM string_search ('the bIG short');

SELECT *
FROM public.find_co_players ('Bryan Cranston')
WHERE
    co_actor = 'Bill Murray';

DELETE FROM movie WHERE movie_id = 'tt32459823';

DELETE FROM series WHERE series_id = 'tt4574334';

DELETE FROM episode WHERE episode_id = 'tt4593118';