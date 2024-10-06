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

# movie import part 1
INSERT INTO
    movie (movie_id, title, re_year)
SELECT tconst, primarytitle, startyear
FROM title_basics
WHERE
    titletype != 'tvEpisode'
    AND titletype != 'tvMiniSeries'
    AND titletype != 'tvSeries'
    AND titletype != 'videoGame';

#movie import part 2¨
##

with
    not_an_epi as (
        SELECT movie_id as not_id
        FROM movie
    ),
    date_not_na as (
        SELECT
            tconst as _id, released,
            CASE
                WHEN released = 'N/A' THEN NULL
                ELSE TO_DATE(released, 'DD Mon YYYY')
            END as release_date
        FROM omdb_data
    )
UPDATE movie    
SET run_time=runtime, poster=omdb_data.poster, plot=omdb_data.plot, release_date=date_not_na.release_date
FROM omdb_data, not_an_epi, date_not_na
WHERE
    tconst = not_an_epi.not_id And tconst = date_not_na._id and tconst = movie_id;


# movie import part 3
UPDATE movie
SET imdb_rating=averagerating
FROM title_ratings
WHERE
    movie_id = tconst;

# series import part 1
INSERT INTO
    series (series_id, title, start_year, end_year)
SELECT tconst, primarytitle, startyear, endyear
FROM title_basics
WHERE
    titletype = 'tvMiniSeries'
    or titletype = 'tvSeries';

# series import part 2

with
    an_seris as (
        SELECT series_id as not_id
        FROM series
    )
UPDATE series
SET poster=omdb_data.poster, plot=omdb_data.plot 
FROM omdb_data, an_seris
WHERE
    tconst = an_seris.not_id and tconst = series_id;  

# series import part 3
UPDATE series
SET imdb_rating=averagerating
FROM title_ratings
WHERE
    series_id = tconst;

# episode import part 1
INSERT INTO
    episode (episode_id, title, re_year)
SELECT tconst, primarytitle, startyear
FROM title_basics
WHERE
    titletype = 'tvEpisode';

# episode import part 2
with
    an_epi as (
        SELECT episode_id as not_id
        FROM episode
    ),
    date_not_na as (
        SELECT
            tconst as _id, released,
            CASE
                WHEN released = 'N/A' THEN NULL
                ELSE TO_DATE(released, 'DD Mon YYYY')
            END as release_date
        FROM omdb_data
    )
UPDATE episode    
SET run_time=runtime, plot=omdb_data.plot, relese_date=date_not_na.release_date
FROM omdb_data, an_epi, date_not_na
WHERE
    tconst = an_epi.not_id And tconst = date_not_na._id and tconst = episode_id;    
 
# episode import part 3
UPDATE episode
SET imdb_rating=averagerating
FROM title_ratings
WHERE
    episode_id = tconst;

# import series episodes relation part 1
INSERT into episode_series (series_id, episode_id, season_number, episode_number)
SELECT tconst, parenttconst, seasonnumber, episodenumber
FROM title_episode;
  
  
SELECT 
FROM title_episode
WHERE episodenumber is NULL;
    
