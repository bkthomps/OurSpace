use our_space;

DROP TABLE IF EXISTS person;
DROP TABLE IF EXISTS sex;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS following_friends;
DROP TABLE IF EXISTS following_groups;
DROP TABLE IF EXISTS topic;
DROP TABLE IF EXISTS post;
DROP TABLE IF EXISTS post_read;

CREATE TABLE person(
	person_id  INT         NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    sex_id     INT         NOT NULL,
    email      VARCHAR(50) NOT NULL,
    passcode   VARCHAR(50) NOT NULL,
    PRIMARY KEY (person_id)
);
INSERT INTO person VALUES (1, 'Bailey Kyle', 'Thompson Rocheleau', 1, 'bkthomps@edu.uwaterloo.ca', 'badpass'),
						  (2, 'Peiyao Rachel', 'Chen', 2, 'p72chen@edu.uwaterloo.ca', 'password');

CREATE TABLE sex(
	sex_id   INT         NOT NULL,
    sex_name VARCHAR(10) NOT NULL,
    PRIMARY KEY (sex_id)
);
INSERT INTO person VALUES (1, 'Male'),
						  (2, 'Female'),
                          (3, 'Other');

CREATE TABLE groups(
	group_id    INT          NOT NULL,
    group_name  VARCHAR(50)  NOT NULL,
    description VARCHAR(500) NOT NULL,
    PRIMARY KEY (group_id)
);
INSERT INTO groups VALUES (1, 'Waterloo Housing', 'Student housing in the Waterloo/Kitchener region'),
						  (2, 'Landlord Tenant Board', 'The Ontario Landlord Tenant Dispute board');

CREATE TABLE following_friends(
	first_person_id  INT NOT NULL,
    second_person_id INT NOT NULL,
    PRIMARY KEY (first_person_id, second_person_id)
);
INSERT INTO following_friends VALUES (1, 2),
									 (2, 1);

CREATE TABLE following_groups(
	person_id INT NOT NULL,
    group_id  INT NOT NULL,
    PRIMARY KEY (person_id, group_id)
);
INSERT INTO following_groups VALUES (1, 2),
									(2, 1);

CREATE TABLE topic(
	topic_id        INT          NOT NULL,
	description     VARCHAR(100) NOT NULL,
    parent_topic_id INT,
    PRIMARY KEY (topic_id)
);
INSERT INTO topic VALUES (1, 'News', NULL);

CREATE TABLE post(
	post_id          INT          NOT NULL,
    content          VARCHAR(500) NOT NULL,
    poster_person_id INT          NOT NULL,
    thumb_up_count   INT          NOT NULL,
    thumb_down_count INT          NOT NULL,
    parent_post_id   INT,
    PRIMARY KEY (post_id)
);
INSERT INTO post VALUES (1, 'First Post', 1, 0, 0, NULL);

CREATE TABLE post_read(
	post_id     INT     NOT NULL,
    person_id   INT     NOT NULL,
    thumbs_up   BOOLEAN NOT NULL,
    thumbs_down BOOLEAN NOT NULL,
    PRIMARY KEY (post_id, person_id)
);
INSERT INTO post_read VALUES (1, 1, FALSE, TRUE);
