-- Table: public.rooms

-- DROP TABLE IF EXISTS public.rooms;

CREATE TABLE IF NOT EXISTS public.rooms
(
    name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    "user" character varying(30) COLLATE pg_catalog."default" NOT NULL,
    "colorRed" numeric(6,5),
    "colorBlue" numeric(6,5),
    "colorGreen" numeric(6,5),
    "colorAlpha" numeric(6,5),
    CONSTRAINT "ROOM_pkey" PRIMARY KEY (name, "user"),
    CONSTRAINT fk_rooms_users FOREIGN KEY ("user")
        REFERENCES public.users (username) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.rooms
    OWNER to jzfcodmvddjeex;