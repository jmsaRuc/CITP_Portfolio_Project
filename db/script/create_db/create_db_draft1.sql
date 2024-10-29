-- Active: 1727253378954@@127.0.0.1@5532@portf_1
BEGIN;


CREATE TABLE IF NOT EXISTS public.movie
(
    movie_id character varying(10) NOT NULL,
    title character varying(256),
    re_year character varying(4),
    run_time character varying(80),
    poster character varying(180),
    plot text,
    language character varying(200),
    release_date date,
    imdb_rating numeric(5, 1),
    ordering integer,
    PRIMARY KEY (movie_id)
	CONSTRAINT imdb_rating_check CHECK ((imdb_rating > (0)::numeric))
);

CREATE TABLE IF NOT EXISTS public.user_interaction
(
    user_id character varying(10),
    movie_id character varying(10),
    series_id character varying(10),
    episode_id character varying(10),
    rating smallint,
    CONSTRAINT rating_check CHECK (rating BETWEEN 1 AND 10),
    whatchlist integer,
    PRIMARY KEY (user_id, movie_id, series_id, episode_id) 
);

CREATE TABLE IF NOT EXISTS public.is_in
(
    person_id character varying(10),
    movie_id character varying(10),
    series_id character varying(10),
    episode_id character varying(10),
    ordering integer,
    job character varying(80),
    character text,
    PRIMARY KEY (person_id, movie_id, series_id, episode_id)
);

CREATE TABLE IF NOT EXISTS public.is_genre
(	
	genre_id character varying(10),
    movie_id character varying(10),
    series_id character varying(10),
    episode_id character varying(10),
    name character varying(256),
    PRIMARY KEY (genre_id, movie_id, series_id, episode_id)
);

CREATE TABLE IF NOT EXISTS public.keywords
(
    movie_id character varying(10),
    series_id character varying(10),
    episode_id character varying(10),
    word text NOT NULL,
    field character varying(1),
    lexeme text,
    PRIMARY KEY (movie_id, series_id, episode_id, word, field)
);

CREATE TABLE IF NOT EXISTS public.person
(
    person_id character varying(10) NOT NULL,
    name character varying(256),
    birth_year character(4),
    death_year character(4),
    primary_profession character varying(256),
    PRIMARY KEY (person_id)
);

CREATE TABLE IF NOT EXISTS public.episode
(
    episode_id character varying(10) NOT NULL,
    title character varying(256),
    re_year character varying(4),
    run_time character varying(80),
    plot text,
    language character varying(200),
    relese_date date,
    imdb_rating numeric(5, 1),
    ordering integer,
    PRIMARY KEY (episode_id)
);

CREATE TABLE IF NOT EXISTS public.episode_series
(
    series_id character varying(10) NOT NULL,
    episode_id character varying(10),
    season_number integer,
    episode_number integer,
    PRIMARY KEY (series_id, episode_id)
);

CREATE TABLE IF NOT EXISTS public.series
(
    series_id character varying(10) NOT NULL,
    title character varying(256),
    start_year character varying(4),
    end_year character varying(4),
    poster character varying(180),
    plot text,
    language character varying(200),
    imdb_rating numeric(5, 1),
    ordering integer,
    PRIMARY KEY (series_id)
);

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


END;