USE our_space;

DROP PROCEDURE IF EXISTS CreateAccount;
DELIMITER $$
CREATE PROCEDURE CreateAccount(
    IN first_name  VARCHAR(50),
    IN last_name   VARCHAR(50),
    IN sex_id      INT,
    IN email       VARCHAR(50),
    IN passcode    VARCHAR(50),
    OUT person_id  BIGINT,
    OUT error_code INT
)
BEGIN
    DECLARE current_person_id BIGINT;
    DECLARE email_count INT;
    SELECT MAX(person.person_id) + 1 INTO current_person_id FROM person;
    SELECT COUNT(person.email) INTO email_count FROM person WHERE person.email = email;
    SET person_id = 0;
    IF first_name = NULL OR CHAR_LENGTH(first_name) = 0 THEN
        SET error_code = 1;
    ELSEIF last_name = NULL OR CHAR_LENGTH(last_name) = 0 THEN
        SET error_code = 2;
    ELSEIF sex_id = NULL OR sex_id < 1 OR sex_id > 3 THEN
        SET error_code = 3;
    ELSEIF email = NULL OR CHAR_LENGTH(email) = 0 THEN
        SET error_code = 4;
	ELSEIF email_count != 0 THEN
        SET error_code = 5;
    ELSEIF passcode = NULL OR CHAR_LENGTH(passcode) < 8 THEN
        SET error_code = 6;
    ELSE
        INSERT INTO person VALUES (current_person_id, first_name, last_name, sex_id, email, passcode);
        SET error_code = 0;
        SET person_id = current_person_id;
    END IF;
END$$
DELIMITER ;

-- CALL CreateAccount('Cave', 'Johnson', 1, 'cave.johnson@aperture.org', 'glados84', @person_id, @error_code);
-- SELECT @person_id;
-- SELECT @error_code;
-- SELECT * FROM person WHERE person_id = 10216646959432839;

DROP PROCEDURE IF EXISTS DeleteAccount;
DELIMITER $$
CREATE PROCEDURE DeleteAccount(
    IN person_id BIGINT
)
BEGIN
    DELETE FROM content_react WHERE reacting_person_id = person_id;
    DELETE FROM comment_reply WHERE comment_reply.person_id = person_id;
    DELETE FROM post_comment WHERE post_comment.person_id = person_id;
    DELETE FROM post WHERE post.person_id = person_id;
    DELETE FROM following_friends WHERE first_person_id = person_id OR second_person_id = person_id;
    DELETE FROM group_admin WHERE group_admin.person_id = person_id;
    DELETE FROM following_groups WHERE following_groups.person_id = person_id;
    DELETE FROM person WHERE person.person_id = person_id;
    -- Note: can result in groups without admins if this user was the only admin in a group
END$$
DELIMITER ;

-- CALL DeleteAccount(10216646959432839, @error_code);
-- SELECT @error_code;
-- SELECT * FROM person WHERE person_id = 10216646959432839;

DROP PROCEDURE IF EXISTS ModifyAccount;
DELIMITER $$
CREATE PROCEDURE ModifyAccount(
    IN person_id   BIGINT,
    IN first_name  VARCHAR(50),
    IN last_name   VARCHAR(50),
    IN sex_id      INT,
    IN email       VARCHAR(50),
    IN passcode    VARCHAR(50),
    OUT error_code INT
)
BEGIN
	DECLARE email_count INT;
    DECLARE person_count INT;
    SELECT COUNT(person.email) INTO email_count FROM person WHERE person.email = email AND person.person_id != person_id;
    SELECT COUNT(person.person_id) INTO person_count FROM person WHERE person.person_id = person_id;
    IF person_count = 0 THEN
        SET error_code = 7;
    ELSEIF first_name = NULL OR CHAR_LENGTH(first_name) = 0 THEN
        SET error_code = 1;
    ELSEIF last_name = NULL OR CHAR_LENGTH(last_name) = 0 THEN
        SET error_code = 2;
    ELSEIF sex_id = NULL OR sex_id < 1 OR sex_id > 3 THEN
        SET error_code = 3;
    ELSEIF email = NULL OR CHAR_LENGTH(email) = 0 THEN
        SET error_code = 4;
	ELSEIF email_count != 0 THEN
        SET error_code = 5;
    ELSEIF passcode = NULL OR CHAR_LENGTH(passcode) < 8 THEN
        SET error_code = 6;
    ELSE
		UPDATE person
			SET person.first_name = first_name, person.last_name = last_name,
				person.sex_id = sex_id, person.email = email, person.passcode = passcode
			WHERE person.person_id = person_id;
        SET error_code = 0;
    END IF;
END$$
DELIMITER ;

-- CALL ModifyAccount(10216646959432839, 'Cave', 'Johnson', 1, 'cave.johnson@aperture.org', 'glados92', @error_code);
-- SELECT @person_id;
-- SELECT @error_code;
-- SELECT * FROM person WHERE person_id = 10216646959432839;
