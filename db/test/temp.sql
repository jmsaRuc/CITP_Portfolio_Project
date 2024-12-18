
CREATE SCHEMA IF NOT EXISTS fuzzy;

CREATE EXTENSION pg_trgm SCHEMA fuzzy;

SET search_path TO public, pgtap, fuzzy;


CREATE Table public.test_movie_keywords AS TABLE public.movie;

ALTER TABLE IF EXISTS public.test_movie_keywords
ADD search tsvector GENERATED ALWAYS AS (setweight(to_tsvector('english', title), 'A') || ' ' ||
to_tsvector('english', plot)) STORED;


CREATE INDEX idx_search ON public.test_movie_keywords USING GIN(search);

-------func







SELECT word FROM public.unique_lexeme WHERE fuzzy.levenshtein(word,'sort') <= 2
ORDER BY fuzzy.levenshtein(word,'sort') ASC
LIMIT 10;

SELECT word FROM public.unique_lexeme WHERE word % 'sort'LIMIT 10;


SELECT word FROM ts_stat('the big short');

SELECT * 
FROM public.test_movie_keywords 
JOIN (
    SELECT word as w
    FROM ts_stat('SELECT search FROM public.test_movie_keywords')
) ts ON true
WHERE fuzzy.levenshtein() < 2;

SELECT n.nspname
FROM pg_extension e
   JOIN pg_namespace n
      ON e.extnamespace = n.oid
WHERE e.extname = 'fuzzystrmatch';


SELECT title, public.get_fuzzy_rank(title, 'the big sort') as rank
FROM public.test_movie_keywords

CREATE INDEX trgm_idx_gin ON test_movie_keywords USING GIN (title gin_trgm_ops);

SELECT public.rank_boost_recent_viewed(movie_id,'ur00016377'::VARCHAR) rank, *
FROM public.test_movie_keywords
ORDER BY rank DESC NULLS LAST;




------------------------how to make rated in the search
with "get" as ( 
SELECT type_id_of as movie_id
FROM public.get_user_recent_view('ur00016377')
) 
SELECT *
FROM public.test_movie_keywords NATURAL JOIN "get"


'the big s'



CREATE INDEX IF NOT EXISTS IX_movie_pop_avg_and_imdb_rating
ON public.test_movie_keywords (popularity DESC);


SELECT ts_rank("search", websearch_to_tsquery('english', 'the bid shor')) 
       + public.numericbooster(imdb_rating, popularity, 5)*0.005 rank, *
   FROM public.test_movie_keywords
   WHERE public.get_fuzzy_rank(title, to_tsquery('english', websearch_to_tsquery('english', 'the bid shor')::text || ':*')::text) > 0.2
   ORDER BY rank DESC NULLS LAST


CREATE INDEX IF NOT EXISTS IX_movie_pop_avg_and_imdb_rating
ON public.test_movie_keywords (popularity DESC, average_rating DESC, imdb_rating DESC);

CREATE INDEX IF NOT EXISTS IX_test_movie_rank on public.test_movie_keywords (rank DESC NULLS LAST); 


--first search for the query

SELECT ts_headline('english', q.title, websearch_to_tsquery('english', 'big short'), 'MaxFragments=3,MaxWords=25,MinWords=2') Highlight, *
FROM (
   SELECT ts_rank(f."search", websearch_to_tsquery('english', 'big short')) 
       + public.rank_boost_rating(imdb_rating, popularity, 5) + public.get_fuzzy_rank(title, 'big short') rank, *
   FROM public.movie_search f, websearch_to_tsquery('english', 'big short') as tsq
   WHERE f."search" @@ to_tsquery('simple', tsq::text || ':*') 
   ORDER BY rank DESC NULLS LAST
) q
WHERE q.rank > 0.001

--- if dont work run fuss 

WITh ranked_search as (
SELECT title,
       ts_rank("search", websearch_to_tsquery('english', 'the bigd shor')) 
       + (public.rank_boost_rating(imdb_rating, popularity, 5)) rank
FROM public.movie_search
ORDER BY rank DESC NULLS LAST
LIMIT 1000
)SELECT ts_headline('english', title, websearch_to_tsquery('english', 'the bigd shor'), 'MaxFragments=3,MaxWords=25,MinWords=2') Highlight, *
FROM ranked_search 
WHERE public.get_fuzzy_rank(title, to_tsquery('english', websearch_to_tsquery('english', 'the bigd shor')::text || ':*')::text) > 0.2














SELECT public.rank_boost_rating(imdb_rating, popularity, 50) rank, *
FROM public.test_movie_keywords
ORDER BY rank DESC NULLS LAST