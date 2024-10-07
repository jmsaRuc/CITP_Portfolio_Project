-- Active: 1727253378954@@127.0.0.1@5532@portf_1@public

SELECT DISTINCT
    titletype
FROM title_basics
WHERE
    titletype IS NOT NULL
ORDER BY "titletype" ASC
LIMIT 100
OFFSET
    1400;

with
    isa_a_seris as (
        SELECT parenttconst as seris
        FROM title_episode
    ),
    is_a_tvshort as (
        SELECT tconst as tvshort
        FROM title_basics
        WHERE
            titletype = 'tvEpisode'
    )
SELECT *
FROM isa_a_seris, is_a_tvshort
WHERE
    seris = tvshort;

-- movie import part 1
INSERT INTO
    movie (movie_id, title, re_year)
SELECT tconst, primarytitle, startyear
FROM title_basics
WHERE
    titletype != 'tvEpisode'
    AND titletype != 'tvMiniSeries'
    AND titletype != 'tvSeries'
    AND titletype != 'videoGame';

--movie import part 2¨
--

with
    not_an_epi as (
        SELECT movie_id as not_id
        FROM movie
    ),
    date_not_na as (
        SELECT
            tconst as _id,
            released,
            CASE
                WHEN released = 'N/A' THEN NULL
                ELSE TO_DATE(released, 'DD Mon YYYY')
            END as release_date
        FROM omdb_data
    )
UPDATE movie
SET
    run_time = runtime,
    poster = omdb_data.poster,
    plot = omdb_data.plot,
    release_date = date_not_na.release_date
FROM
    omdb_data,
    not_an_epi,
    date_not_na
WHERE
    tconst = not_an_epi.not_id
    And tconst = date_not_na._id
    and tconst = movie_id;

-- movie import part 3
UPDATE movie
SET
    imdb_rating = averagerating
FROM title_ratings
WHERE
    movie_id = tconst;

-- series import part 1
INSERT INTO
    series (
        series_id,
        title,
        start_year,
        end_year
    )
SELECT
    tconst,
    primarytitle,
    startyear,
    endyear
FROM title_basics
WHERE
    titletype = 'tvMiniSeries'
    or titletype = 'tvSeries';

-- series import part 2

with
    an_seris as (
        SELECT series_id as not_id
        FROM series
    )
UPDATE series
SET
    poster = omdb_data.poster,
    plot = omdb_data.plot
FROM omdb_data, an_seris
WHERE
    tconst = an_seris.not_id
    and tconst = series_id;
-- series import part 3
UPDATE series
SET
    imdb_rating = averagerating
FROM title_ratings
WHERE
    series_id = tconst;

-- episode import part 1
INSERT INTO
    episode (episode_id, title, re_year)
SELECT tconst, primarytitle, startyear
FROM title_basics
WHERE
    titletype = 'tvEpisode';

-- episode import part 2
with
    an_epi as (
        SELECT episode_id as not_id
        FROM episode
    ),
    date_not_na as (
        SELECT
            tconst as _id,
            released,
            CASE
                WHEN released = 'N/A' THEN NULL
                ELSE TO_DATE(released, 'DD Mon YYYY')
            END as release_date
        FROM omdb_data
    )
UPDATE episode
SET
    run_time = runtime,
    plot = omdb_data.plot,
    relese_date = date_not_na.release_date
FROM omdb_data, an_epi, date_not_na
WHERE
    tconst = an_epi.not_id
    And tconst = date_not_na._id
    and tconst = episode_id;
-- episode import part 3
UPDATE episode
SET
    imdb_rating = averagerating
FROM title_ratings
WHERE
    episode_id = tconst;

-- import series episodes relation part 1
INSERT into
    episode_series (
        series_id,
        episode_id,
        season_number,
        episode_number
    )
SELECT
    parenttconst,
    tconst,
    seasonnumber,
    episodenumber
FROM title_episode;
-- import person part 1
INSERT INTO
    person (
        person_id,
        name,
        birth_year,
        death_year,
        primary_profession
    )
SELECT
    nconst,
    primaryname,
    birthyear,
    deathyear,
    split_part(primaryprofession, ',', 1) as primary_profession
FROM name_basics;

-- movie_genre
INSERT INTO
    movie_genre (genre_name, movie_id)
SELECT string_to_table(genres, ',') as genre, tconst
FROM title_basics
WHERE
    genres IS NOT NULL
    and titletype != 'tvEpisode'
    AND titletype != 'tvMiniSeries'
    AND titletype != 'tvSeries'
    AND titletype != 'videoGame';

-- series_genre
INSERT INTO
    series_genre (genre_name, series_id)
SELECT string_to_table(genres, ',') as genre, tconst
FROM title_basics
WHERE
    genres IS NOT NULL
    and titletype = 'tvMiniSeries'
    or titletype = 'tvSeries';

-- episode_genre
INSERT INTO
    episode_genre (genre_name, episode_id)
SELECT string_to_table(genres, ',') as genre, tconst
FROM title_basics
WHERE
    genres IS NOT NULL
    and titletype = 'tvEpisode';

-- is_in_movie
INSERT INTO
    is_in_movie (
        person_id,
        movie_id,
        cast_order,
        role,
        job,
        character
    )
with
    titletype_movie as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype != 'tvEpisode'
            AND titletype != 'tvMiniSeries'
            AND titletype != 'tvSeries'
            AND titletype != 'videoGame'
    )
SELECT
    nconst,
    tconst,
    ordering,
    category,
    job,
    characters
FROM
    title_principals
    NATURAL JOIN titletype_movie;

-- is_in_series
INSERT INTO
    is_in_series (
        person_id,
        series_id,
        cast_order,
        role,
        job,
        character
    )
with
    titletype_series as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvMiniSeries'
            or titletype = 'tvSeries'
    )
SELECT
    nconst,
    tconst,
    ordering,
    category,
    job,
    characters
FROM
    title_principals
    NATURAL JOIN titletype_series;

-- is_in_episode
INSERT INTO
    is_in_episode (
        person_id,
        episode_id,
        cast_order,
        role,
        job,
        character
    )
with
    titletype_episode as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvEpisode'
    )
SELECT
    nconst,
    tconst,
    ordering,
    category,
    job,
    characters
FROM
    title_principals
    NATURAL JOIN titletype_episode;

-- movie_keywords

INSERT INTO
    movie_keywords (movie_id, word, field, lexeme)
with
    titletype_episode as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype != 'tvEpisode'
            AND titletype != 'tvMiniSeries'
            AND titletype != 'tvSeries'
            AND titletype != 'videoGame'
    )
SELECT wi.tconst, word, field, lexeme
FROM wi
    NATURAL JOIN titletype_episode;

-- series_keywords
INSERT INTO
    series_keywords (
        series_id,
        word,
        field,
        lexeme
    )
with
    titletype_series as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvMiniSeries'
            or titletype = 'tvSeries'
    )
SELECT wi.tconst, word, field, lexeme
FROM wi
    NATURAL JOIN titletype_series;

-- episode_keywords
INSERT INTO
    episode_keywords (
        episode_id,
        word,
        field,
        lexeme
    )
with
    titletype_episode as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvEpisode'
    )
SELECT wi.tconst, word, field, lexeme
FROM wi
    NATURAL JOIN titletype_episode;

-- movie_language
INSERT INTO
    movie_language (language, movie_id)
with
    titletype_movie as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype != 'tvEpisode'
            AND titletype != 'tvMiniSeries'
            AND titletype != 'tvSeries'
            AND titletype != 'videoGame'
    )
SELECT string_to_table(language, ','), omdb_data.tconst
FROM omdb_data
    NATURAL JOIN titletype_movie;

-- series_language
INSERT INTO
    series_language (language, series_id)
with
    titletype_series as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvMiniSeries'
            or titletype = 'tvSeries'
    )
SELECT string_to_table(language, ','), omdb_data.tconst
FROM omdb_data
    NATURAL JOIN titletype_series;

-- episode_language
INSERT INTO
    episode_language (language, episode_id)
with
    titletype_episode as (
        SELECT tconst
        FROM title_basics
        WHERE
            titletype = 'tvEpisode'
    )
SELECT string_to_table(language, ','), omdb_data.tconst
FROM omdb_data
    NATURAL JOIN titletype_episode;

-- import type

##
INSERT INTO public.type (type_id, title_type)
with
    type_change as (
        SELECT
            tconst,
            titletype,
            CASE
                WHEN titletype = 'tvEpisode' THEN 'episode'
                WHEN titletype = 'tvMiniSeries' THEN 'series'
                WHEN titletype = 'tvSeries' THEN 'series'
                WHEN titletype = 'videoGame' THEN NULL
                ELSE 'movie'
            END as type_name_v
        FROM title_basics
    )
SELECT tconst, type_change.type_name_v
FROM type_change
WHERE
    type_change.type_name_v IS NOT NULL;

-- import person type

INSERT INTO public.type (type_id, title_type)
SELECT person_id, 'person' 
FROM person
   