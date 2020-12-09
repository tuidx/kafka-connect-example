DROP TABLE IF EXISTS "public"."user" CASCADE ;
CREATE TABLE "public".user (
	id bigserial PRIMARY KEY,
	name VARCHAR(250) NOT NULL UNIQUE,
	email VARCHAR(250) NOT NULL UNIQUE,
	last_name VARCHAR(100) NOT NULL
)WITH (oids = false);
