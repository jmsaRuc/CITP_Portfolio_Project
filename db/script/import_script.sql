-- Active: 1727253378954@@127.0.0.1@5532@portf_1
SELECT DISTINCT titletype
FROM title_basics
WHERE titletype IS NOT NULL  
ORDER BY "titletype" ASC LIMIT 100 OFFSET 1400;

with 
     isa_a_seris as (
        SELECT parenttconst as seris
        FROM title_episode
     ),
     is_a_tvshort as (
        SELECT tconst as tvshort
        FROM title_basics
        WHERE titletype = 'tvEpisode'
     )
SELECT *
FROM isa_a_seris, is_a_tvshort
WHERE seris = tvshort;

#movie import part 1 
INSERT INTO movie (movie_id, title, re_year)
SELECT tconst, primarytitle, startyear
FROM title_basics
WHERE titletype != 'tvEpisode' AND titletype != 'tvMiniSeries' AND titletype != 'tvSeries' AND titletype != 'videoGame';
INSERT INTO movie (movie_id, title, re_year)
