-- Active: 1727253378954@@127.0.0.1@5532@import_for_portf_1@public
BEGIN;


CREATE TABLE IF NOT EXISTS public.movie
(
    movie_id character varying(10) NOT NULL,
    title character varying(256) NOT NULL,
    re_year character varying(4),
    run_time character varying(80),
    poster character varying(180),
    plot text,
    language character varying(200),
    release_date date,
    imdb_rating numeric(5, 1),
	CONSTRAINT imdb_rating_check CHECK ((imdb_rating > (0)::numeric)),
    popularity integer,
    CONSTRAINT popularity_check CHECK ((popularity > (0)::integer)),
    PRIMARY KEY (movie_id)
);

CREATE TABLE IF NOT EXISTS public.user_interaction
(
    user_id character varying(10) NOT NULL,
    movie_id character varying(10),
    series_id character varying(10),
    episode_id character varying(10),
    rating smallint,
	CONSTRAINT rating_check CHECK (rating BETWEEN 1 AND 10),
    watchlist integer,
    CONSTRAINT watchlist_check CHECK ((watchlist > (0)::integer)),
    PRIMARY KEY (user_id, movie_id, series_id, episode_id) 
);

CREATE TABLE IF NOT EXISTS public.is_in
(
    person_id character varying(10) NOT NULL,
    movie_id character varying(10),
    series_id character varying(10),
    episode_id character varying(10),
    popularity integer,
    CONSTRAINT popularity_check CHECK ((popularity > (0)::integer)),
    job character varying(80),
    character character varying(256),
    PRIMARY KEY (person_id, movie_id, series_id, episode_id)
);

CREATE TABLE IF NOT EXISTS public.is_genre
(   
    genre_name character varying(256) NOT NULL,
    movie_id character varying(10),
    series_id character varying(10),
    episode_id character varying(10),
    PRIMARY KEY (genre_name, movie_id, episode_id, series_id)
);

CREATE TABLE IF NOT EXISTS public.keywords
(   
    movie_id character varying(10),
    series_id character varying(10),
    episode_id character varying(10),
    person_id character varying(10),
    word text NOT NULL,
    field character varying(1) NOT NULL,
    lexeme text,
    PRIMARY KEY (movie_id, series_id, episode_id, person_id, word, field)
);


CREATE TABLE IF NOT EXISTS public.person
(
    person_id character varying(10) NOT NULL,
    name character varying(256) NOT NULL,
    birth_year character(4),
    death_year character(4),
    primary_profession character varying(256),
    PRIMARY KEY (person_id)
);

CREATE TABLE IF NOT EXISTS public.episode
(
    episode_id character varying(10) NOT NULL,
    title character varying(256) NOT NULL,
    re_year character varying(4),
    run_time character varying(80),
    plot text,
    language character varying(200),
    relese_date date,
    imdb_rating numeric(5, 1),
    CONSTRAINT imdb_rating_check CHECK ((imdb_rating > (0)::numeric)),
    popularity integer,
    CONSTRAINT popularity_check CHECK ((popularity > (0)::integer)),
    PRIMARY KEY (episode_id)
);

CREATE TABLE IF NOT EXISTS public.episode_series
(
    series_id character varying(10) NOT NULL,
    episode_id character varying(10),
    season_number integer,
    CONSTRAINT season_number_check CHECK ((season_number > (0)::integer)),
    episode_number integer,
    CONSTRAINT episode_number_check CHECK ((episode_number > (0)::integer)),
    PRIMARY KEY (series_id, episode_id)
);

CREATE TABLE IF NOT EXISTS public.series
(
    series_id character varying(10) NOT NULL,
    title character varying(256) NOT NULL,
    start_year character varying(4),
    end_year character varying(4),
    poster character varying(180),
    plot text,
    language character varying(200),
    imdb_rating numeric(5, 1),
    CONSTRAINT imdb_rating_check CHECK ((imdb_rating > (0)::numeric)),
    popularity integer,
    CONSTRAINT popularity_check CHECK ((popularity > (0)::integer)),
    PRIMARY KEY (series_id)
);

CREATE TABLE IF NOT EXISTS public.user
(
    user_id character varying(10) NOT NULL,
    username character varying(256) NOT NULL,
    password bytea NOT NULL,
    email character varying(256) NOT NULL,
    created_at date,
    PRIMARY KEY (user_id)
);

CREATE TABLE IF NOT EXISTS public.recent_view
(
    user_id character varying(10) NOT NULL,
    movie_id character varying(10),
    series_id character varying(10),
    episode_id character varying(10),
    person_id character varying(10),
    view_ordering integer,
    CONSTRAINT view_ordering CHECK ((view_ordering > (0)::integer)),
    watchlist integer,
    PRIMARY KEY (user_id, movie_id, series_id, episode_id, person_id)
);

ALTER TABLE IF EXISTS public.user_interaction
    ADD FOREIGN KEY (user_id)
    REFERENCES public.user (user_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;

ALTER TABLE IF EXISTS public.user_interaction
    ADD FOREIGN KEY (movie_id)
    REFERENCES public.movie (movie_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;



ALTER TABLE IF EXISTS public.user_interaction
    ADD FOREIGN KEY (series_id)
    REFERENCES public.series (series_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.user_interaction
    ADD FOREIGN KEY (episode_id)
    REFERENCES public.episode (episode_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;

ALTER TABLE IF EXISTS public.is_in
    ADD FOREIGN KEY (person_id)
    REFERENCES public.person (person_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;

ALTER TABLE IF EXISTS public.is_in
    ADD FOREIGN KEY (movie_id)
    REFERENCES public.movie (movie_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;

 
ALTER TABLE IF EXISTS public.is_in
    ADD FOREIGN KEY (series_id)
    REFERENCES public.series (series_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.is_in
    ADD FOREIGN KEY (episode_id)
    REFERENCES public.episode (episode_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.is_genre
    ADD FOREIGN KEY (movie_id)
    REFERENCES public.movie (movie_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.is_genre
    ADD FOREIGN KEY (series_id)
    REFERENCES public.series (series_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.is_genre
    ADD FOREIGN KEY (episode_id)
    REFERENCES public.episode (episode_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;
 

ALTER TABLE IF EXISTS public.keywords
    ADD FOREIGN KEY (movie_id)
    REFERENCES public.movie (movie_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.keywords
    ADD FOREIGN KEY (series_id)
    REFERENCES public.series (series_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.keywords
    ADD FOREIGN KEY (episode_id)
    REFERENCES public.episode (episode_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.keywords
    ADD FOREIGN KEY (person_id)
    REFERENCES public.person (person_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;

ALTER TABLE IF EXISTS public.episode_series
    ADD FOREIGN KEY (series_id)
    REFERENCES public.series (series_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;

ALTER TABLE IF EXISTS public.episode_series
    ADD FOREIGN KEY (episode_id)
    REFERENCES public.episode (episode_id) MATCH SIMPLE 
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID; 


ALTER TABLE IF EXISTS public.recent_view
    ADD FOREIGN KEY (user_id)
    REFERENCES public.user (user_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.recent_view
    ADD FOREIGN KEY (movie_id)
    REFERENCES public.movie (movie_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.recent_view
    ADD FOREIGN KEY (series_id)
    REFERENCES public.series (series_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.recent_view
    ADD FOREIGN KEY (episode_id)
    REFERENCES public.episode (episode_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;


ALTER TABLE IF EXISTS public.recent_view
    ADD FOREIGN KEY (person_id)
    REFERENCES public.person (person_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT VALID;

END;