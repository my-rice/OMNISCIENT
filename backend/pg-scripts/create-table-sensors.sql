-- Table: public.sensors

-- DROP TABLE IF EXISTS public.sensors;

CREATE TABLE IF NOT EXISTS public.sensors
(
    id character varying(30) COLLATE pg_catalog."default" NOT NULL,
    name character varying(30) COLLATE pg_catalog."default",
    type character varying(30) COLLATE pg_catalog."default" NOT NULL,
    room_name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    room_user character varying(30) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "SENSOR_pkey" PRIMARY KEY (id),
    CONSTRAINT fk_sensors_rooms FOREIGN KEY (room_name, room_user)
        REFERENCES public.rooms (name, "user") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sensors
    OWNER to jzfcodmvddjeex;