--remove old data
SET client_encoding = 'LATIN1';
set search_path=public;
drop table if exists users cascade;
drop table if exists personalinterests cascade;
drop table if exists project cascade;
drop table if exists community cascade;
drop table if exists communityendorsement cascade;
drop table if exists initiator cascade;
drop table if exists funder cascade;
drop table if exists rating cascade;
drop table if exists session cascade;

----------------------------------------------------------------------
-------------users table--------------------------------------------
----------------------------------------------------------------------
CREATE TABLE users 
(
    email character varying(40) NOT NULL,
    fname character varying(40) NOT NULL,
    lname character varying(40) NOT NULL,
    password character varying(40) NOT NULL,
    reputation integer NOT NULL,
    profession character varying(40),
	admin integer NOT NULL
);
ALTER TABLE ONLY users ADD CONSTRAINT users_pkey PRIMARY KEY (email);


----------------------------------------------------------------------
-------------personalintersts table-----------------------------------
----------------------------------------------------------------------
CREATE TABLE personalinterests 
(
    email character varying(40) NOT NULL,
    commid integer NOT NULL
);
ALTER TABLE ONLY personalinterests ADD CONSTRAINT personalinterests_pkey PRIMARY KEY (email, commid);
ALTER TABLE ONLY personalinterests
    ADD CONSTRAINT personalinterests_email_fkey FOREIGN KEY (email) REFERENCES users(email);
ALTER TABLE ONLY personalinterests
    ADD CONSTRAINT personalinterests_commid_fkey FOREIGN KEY (commid) REFERENCES community(commid);

----------------------------------------------------------------------
-------------project table--------------------------------------------
----------------------------------------------------------------------
CREATE TABLE project 
(
    projid integer NOT NULL,
    goalamount integer NOT NULL,
    curramount integer NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL,
    description character varying(100),
    location character varying(40) NOT NULL,
    popularity integer NOT NULL,
    rating double precision NOT NULL,
	longdesc character varying(1000)
);
CREATE SEQUENCE project_projid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE ONLY project ALTER COLUMN projid SET DEFAULT nextval('project_projid_seq'::regclass);
SELECT pg_catalog.setval('project_projid_seq', 3, false);
ALTER TABLE ONLY project ADD CONSTRAINT project_pkey PRIMARY KEY (projid);

----------------------------------------------------------------------
-------------community table--------------------------------------------
----------------------------------------------------------------------
CREATE TABLE community 
(
    commid integer NOT NULL,
    description character varying(100) NOT NULL
);
CREATE SEQUENCE community_commid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE ONLY community ALTER COLUMN commid SET DEFAULT nextval('community_commid_seq'::regclass);
SELECT pg_catalog.setval('community_commid_seq', 2, false);
ALTER TABLE ONLY community ADD CONSTRAINT community_pkey PRIMARY KEY (commid);

----------------------------------------------------------------------
-------------communityendorsement table--------------------------------------------
----------------------------------------------------------------------
CREATE TABLE communityendorsement 
(
    commid integer NOT NULL,
    projid integer NOT NULL
);
ALTER TABLE ONLY communityendorsement ADD CONSTRAINT communityendorsement_pkey PRIMARY KEY (projid, commid);
ALTER TABLE ONLY communityendorsement
    ADD CONSTRAINT communityendorsement_commid_fkey FOREIGN KEY (commid) REFERENCES community(commid);
ALTER TABLE ONLY communityendorsement
    ADD CONSTRAINT communityendorsement_projid_fkey FOREIGN KEY (projid) REFERENCES project(projid);


----------------------------------------------------------------------
-------------initiator table--------------------------------------------
----------------------------------------------------------------------
CREATE TABLE initiator 
(
    projid integer NOT NULL,
    email character varying(40) NOT NULL
);
ALTER TABLE ONLY initiator ADD CONSTRAINT initiator_pkey PRIMARY KEY (projid, email);
ALTER TABLE ONLY initiator
    ADD CONSTRAINT initiator_email_fkey FOREIGN KEY (email) REFERENCES users(email);
ALTER TABLE ONLY initiator
    ADD CONSTRAINT initiator_projid_fkey FOREIGN KEY (projid) REFERENCES project(projid);

----------------------------------------------------------------------
-------------funder table--------------------------------------------
----------------------------------------------------------------------
CREATE TABLE funder 
(
    fundid integer NOT NULL,
    email character varying(40) NOT NULL,
    projid integer NOT NULL,
    datestamp date NOT NULL,
    amount integer NOT NULL
);
CREATE SEQUENCE funder_fundid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE ONLY funder ALTER COLUMN fundid SET DEFAULT nextval('funder_fundid_seq'::regclass);
SELECT pg_catalog.setval('funder_fundid_seq', 5, false);
ALTER TABLE ONLY funder ADD CONSTRAINT funder_pkey PRIMARY KEY (fundid);
ALTER TABLE ONLY funder
    ADD CONSTRAINT funder_email_fkey FOREIGN KEY (email) REFERENCES users(email);
ALTER TABLE ONLY funder
    ADD CONSTRAINT funder_projid_fkey FOREIGN KEY (projid) REFERENCES project(projid);

----------------------------------------------------------------------
-------------ratings table--------------------------------------------
----------------------------------------------------------------------
CREATE TABLE rating (
    rid integer NOT NULL,
    projid integer NOT NULL,
    email character varying(40),
	rating integer NOT NULL
);
CREATE SEQUENCE rating_rid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE ONLY rating ALTER COLUMN rid SET DEFAULT nextval('rating_rid_seq'::regclass);
SELECT pg_catalog.setval('rating_rid_seq', 2, false);
ALTER TABLE ONLY rating
    ADD CONSTRAINT rating_pkey PRIMARY KEY (rid);
ALTER TABLE ONLY rating
    ADD CONSTRAINT rating_email_fkey FOREIGN KEY (email) REFERENCES users(email);
ALTER TABLE ONLY rating
    ADD CONSTRAINT rating_projid_fkey FOREIGN KEY (projid) REFERENCES project(projid);

----------------------------------------------------------------------
-------------session information table--------------------------------
----------------------------------------------------------------------
CREATE TABLE session (
    email character varying(40) NOT NULL,
    sessionid integer,
    expiration timestamp without time zone
);
ALTER TABLE ONLY session
    ADD CONSTRAINT session_pkey PRIMARY KEY (email);
ALTER TABLE ONLY session
    ADD CONSTRAINT session_email_fkey FOREIGN KEY (email) REFERENCES users(email);

-----------------------------------------------------------------
-----------------------sample data info--------------------------
--* 3 Main users at the top
--* 2 Interests/main user
--* Everyone belongs to "raildex tv characters" community
--* The community endorses both projects
--* Each project has 1 initator
--* Each project has 2 funders from random other characters seen on the show

--add users as well as other characters from the show as donors
COPY users (email, fname, lname, password, reputation, admin) FROM stdin;
right_hand@raildex.tv	Touma	Kamijou	unlucky	100	0
libprohibited@raildex.tv	Index	Prohibited	feedme	100	0
zapper@raildex.tv	Mikoto	Misaka	railgun	100	0
creepo@raildex.tv	Touya	Kamijou	dad	100	0
whitehat@raildex.tv	Something	Uiharu	flowers	100	0
legends@raildex.tv	Ruiko	Saten	superstition	100	0
root	Absolute	Authority	toor	0	1
\.

COPY community (commid, description) FROM stdin;
1	Magic
2	Cat care
3	Gourmet Eating
4	Technology
5	Education
6	Interior Design
\.

COPY personalinterests (email, commid) FROM stdin;
right_hand@raildex.tv	1
right_hand@raildex.tv	2
libprohibited@raildex.tv	2
libprohibited@raildex.tv	3
zapper@raildex.tv	4
\.

COPY project (projid, goalamount, curramount, startdate, enddate, description, location, popularity, rating, longdesc) FROM stdin;
1	500	20	2015-2-21	2015-06-21	Get a bunk bed for Toumas room	Toumas Appartment	100	0	Please help me so that I wont have to sleep in the bathtub every night. For obvious reasons Index doesnt want to sleep in the same bed with me so I was hoping to get a bunk bed where I can sleep on the bottom row. That way Index wont have to worry about personal safety and I wont have to wake up sore every morning.
2	50000	1000	2015-2-21	2016-2-21	Make gigabit wifi available citywide	Academy City	100	0	Imagine the convenience of having internet access wherever you go. All the worlds information at your fingertips. No more need to go to internet cafes or telephone booths. This will be especially andy for those who like to say up late and dont want to always be seen alone in a phone both.
\.


COPY communityendorsement (commid, projid) FROM stdin;
6	1
4	2
\.

COPY initiator (projid, email) FROM stdin;
1	right_hand@raildex.tv
2	zapper@raildex.tv
\.

--the large donation for project 2 was from the extra money cards
COPY funder (fundid, email, projid, datestamp, amount) FROM stdin;
1	libprohibited@raildex.tv	1	2015-2-26	5
2	creepo@raildex.tv	1	2015-2-22	15
3	whitehat@raildex.tv	2	2015-2-25	20
4	legends@raildex.tv	2	2015-3-1	980
\.

COPY rating (rid, projid, email, rating) FROM stdin;
1	2	whitehat@raildex.tv	5
\.

COPY session (email, expiration) FROM stdin;
right_hand@raildex.tv	2020-03-06 19:03:17.433082-05
libprohibited@raildex.tv	2000-03-06 19:03:17.433082-05
zapper@raildex.tv	2000-03-06 19:03:17.433082-05
creepo@raildex.tv	2000-03-06 19:03:17.433082-05
whitehat@raildex.tv	2000-03-06 19:03:17.433082-05
legends@raildex.tv	2000-03-06 19:03:17.433082-05
root	2099-03-06 19:03:17.433082-05
\.
