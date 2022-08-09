-- Table: public.actuators

-- DROP TABLE IF EXISTS public.actuators;

CREATE TABLE IF NOT EXISTS public.actuators
(
    id character varying(30) COLLATE pg_catalog."default" NOT NULL,
    name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    type character varying(30) COLLATE pg_catalog."default" NOT NULL,
    owner character varying(30) COLLATE pg_catalog."default" NOT NULL,
    room character varying(30) COLLATE pg_catalog."default",
    CONSTRAINT actuators_pkey PRIMARY KEY (id),
    CONSTRAINT fk_owner FOREIGN KEY (owner)
        REFERENCES public.users (username) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_room FOREIGN KEY (owner, room)
        REFERENCES public.rooms ("user", name) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.actuators
    OWNER to jzfcodmvddjeex;