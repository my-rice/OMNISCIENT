-- Table: public.cameras

-- DROP TABLE IF EXISTS public.cameras;

CREATE TABLE IF NOT EXISTS public.cameras
(
    name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    room_name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    room_user character varying(30) COLLATE pg_catalog."default" NOT NULL,
    domain character varying(100) COLLATE pg_catalog."default" NOT NULL,
    port character varying(6) COLLATE pg_catalog."default" NOT NULL,
    username character varying(30) COLLATE pg_catalog."default",
    password character varying(30) COLLATE pg_catalog."default",
    protocol character varying(10) COLLATE pg_catalog."default" NOT NULL DEFAULT 'RTSP'::character varying,
    CONSTRAINT cameras_pkey PRIMARY KEY (name, room_name, room_user),
    CONSTRAINT cameras_room_name_room_user_fkey FOREIGN KEY (room_name, room_user)
        REFERENCES public.rooms (name, "user") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.cameras
    OWNER to jzfcodmvddjeex;