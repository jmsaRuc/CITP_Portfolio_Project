-- Active: 1727253378954@@127.0.0.1@5532@portf_1
--------------------------------------old 
----- D2 simple search
CREATE OR REPLACE FUNCTION "public"."string_search"(S text) 
  RETURNS TABLE(id varchar, title varchar) AS $$ 
BEGIN 
    RETURN QUERY 
    SELECT  
        movie_id AS id,  
        movie.title  
    FROM public. 
        movie 
    WHERE 
        LOWER(movie.title) LIKE LOWER('%' || S || '%') or 
        LOWER(movie.plot) LIKE LOWER('%' || S || '%'); 
END; 
$$ LANGUAGE plpgsql;

---------------old 

--- D6
CREATE OR REPLACE VIEW actorcoplayers AS
SELECT is_in_movie.movie_id, person.person_id, person.name, movie.title, is_in_movie.role
FROM public.is_in_movie
    JOIN person ON is_in_movie.person_id::TEXT = person.person_id::TEXT
    JOIN movie ON is_in_movie.movie_id::TEXT = movie.movie_id::TEXT
WHERE
    lower(is_in_movie.role::TEXT) = ANY (
        ARRAY[
            'actor'::TEXT,
            'actress'::TEXT
        ]
    );

CREATE OR REPLACE FUNCTION "public"."find_co_players"(actorname text) 
  RETURNS TABLE("actor" varchar, "co_actor" varchar, "frequency" int8) AS $$ 
  BEGIN 
   RETURN QUERY 
    WITH actor_movies AS ( 
        SELECT actorcoplayers.movie_id 
        FROM public.actorcoplayers
        WHERE actorcoplayers.name = actorname
        ), 
        count_actor AS ( 
            SELECT actorcoplayers.person_id AS actor, 
            actorcoplayers.name AS co_actor, 
            COUNT(*) AS frequency 
            FROM public.actorcoplayers 
            JOIN actor_movies on actorcoplayers.movie_id = actor_movies.movie_id 
            WHERE actorcoplayers.name != actorname 
            GROUP BY actorcoplayers.person_id, actorcoplayers.name 
         ) 
        SELECT  
        count_actor.actor, 
        count_actor.co_actor, 
        count_actor.frequency 
    FROM count_actor 
           ORDER BY  
        frequency DESC; 
        END; 
$$ 
LANGUAGE plpgsql VOLATILE;