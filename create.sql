USE our_space;

DROP TABLE IF EXISTS person;
DROP TABLE IF EXISTS sex;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS following_friends;
DROP TABLE IF EXISTS following_groups;
DROP TABLE IF EXISTS post;
DROP TABLE IF EXISTS post_comment;
DROP TABLE IF EXISTS comment_reply;
DROP TABLE IF EXISTS react_type;
DROP TABLE IF EXISTS content_react;

CREATE TABLE person(
	person_id  BIGINT      NOT NULL,
	first_name VARCHAR(50) NOT NULL,
	last_name  VARCHAR(50) NOT NULL,
	sex_id     INT         NOT NULL,
	email      VARCHAR(50) NOT NULL,
	passcode   VARCHAR(50) NOT NULL,
	PRIMARY KEY (person_id)
);

CREATE TABLE sex(
	sex_id   INT         NOT NULL,
	sex_name VARCHAR(10) NOT NULL,
	PRIMARY KEY (sex_id)
);

CREATE TABLE groups(
	group_id    BIGINT      NOT NULL,
	group_name  VARCHAR(50) NOT NULL,
	PRIMARY KEY (group_id)
);

CREATE TABLE following_friends(
	first_person_id  BIGINT NOT NULL,
	second_person_id BIGINT NOT NULL,
	PRIMARY KEY (first_person_id, second_person_id)
);

CREATE TABLE following_groups(
	person_id BIGINT NOT NULL,
	group_id  BIGINT NOT NULL,
	PRIMARY KEY (person_id, group_id)
);

CREATE TABLE post(
	post_id    BIGINT         NOT NULL,
	content    VARCHAR(15000) NOT NULL,
	person_id  BIGINT         NOT NULL,
	group_id   BIGINT         NOT NULL,
	time_stamp VARCHAR(20)    NOT NULL,
	likes      INT            NOT NULL,
	shares     INT            NOT NULL,
	PRIMARY KEY (post_id)
);

CREATE TABLE post_comment(
	comment_id BIGINT         NOT NULL,
	content    VARCHAR(15000) NOT NULL,
	person_id  BIGINT         NOT NULL,
	group_id   BIGINT         NOT NULL,
	time_stamp VARCHAR(20)    NOT NULL,
	post_id    BIGINT         NOT NULL,
	PRIMARY KEY (comment_id)
);

CREATE TABLE comment_reply(
	reply_id   BIGINT         NOT NULL,
	content    VARCHAR(15000) NOT NULL,
	person_id  BIGINT         NOT NULL,
	group_id   BIGINT         NOT NULL,
	time_stamp VARCHAR(20)    NOT NULL,
	post_id    BIGINT         NOT NULL,
	comment_id BIGINT         NOT NULL,
	PRIMARY KEY (reply_id)
);

CREATE TABLE react_type(
	react_id   INT         NOT NULL,
	react_name VARCHAR(10) NOT NULL,
	PRIMARY KEY (react_id)
);

CREATE TABLE content_react(
	content_id         BIGINT NOT NULL,
	reacting_person_id BIGINT NOT NULL,
	reaction_type      INT    NOT NULL,
	PRIMARY KEY (content_id, reacting_person_id)
);
