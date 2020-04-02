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
