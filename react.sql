USE our_space;

DROP PROCEDURE IF EXISTS CreateReaction;
DELIMITER $$
CREATE PROCEDURE CreateReaction(
    IN content_id         BIGINT,
    IN reacting_person_id BIGINT,
    IN reaction_type      INT,
    OUT error_code        INT
)
BEGIN
	DECLARE person_count INT;
	DECLARE post_count INT;
    DECLARE comment_count INT;
    DECLARE reply_count INT;
    SELECT COUNT(person.person_id) INTO person_count FROM person WHERE person.person_id = reacting_person_id;
    SELECT COUNT(*) INTO post_count FROM post WHERE post_id = content_id;
    SELECT COUNT(*) INTO comment_count FROM post_comment WHERE comment_id = content_id;
    SELECT COUNT(*) INTO reply_count FROM comment_reply WHERE reply_id = content_id;
    IF person_count != 1 THEN
		SET error_code = 1;
    ELSEIF post_count + comment_count + reply_count = 0 THEN
		SET error_code = 2;
	ELSEIF post_count + comment_count + reply_count > 1 THEN
		SET error_code = 3;
	ELSEIF reaction_type < 1 OR reaction_type > 6 THEN
		SET error_code = 4;
    ELSE
        DELETE FROM content_react
			WHERE content_react.content_id = content_id AND content_react.reacting_person_id = reacting_person_id;
		INSERT INTO content_react VALUES (content_id, reacting_person_id, reaction_type);
        SET error_code = 0;
    END IF;
END$$
DELIMITER ;

-- CALL CreateReaction(0, 10216646959432839, 1, @error_code);
-- SELECT @error_code;
-- CALL CreateReaction(1217805638231620, 0, 1, @error_code);
-- SELECT @error_code;
-- CALL CreateReaction(1217805638231620, 10216646959432839, 1, @error_code);
-- SELECT @error_code;
-- CALL CreateReaction(1217805638231620, 10216646959432839, 1, @error_code);
-- SELECT @error_code;

DROP PROCEDURE IF EXISTS DeleteReaction;
DELIMITER $$
CREATE PROCEDURE DeleteReaction(
    IN content_id         BIGINT,
    IN reacting_person_id BIGINT,
    OUT error_code        INT
)
BEGIN
	DECLARE person_count INT;
	DECLARE post_count INT;
    DECLARE comment_count INT;
    DECLARE reply_count INT;
    SELECT COUNT(person.person_id) INTO person_count FROM person WHERE person.person_id = reacting_person_id;
    SELECT COUNT(*) INTO post_count FROM post WHERE post_id = content_id;
    SELECT COUNT(*) INTO comment_count FROM post_comment WHERE comment_id = content_id;
    SELECT COUNT(*) INTO reply_count FROM comment_reply WHERE reply_id = content_id;
    IF person_count != 1 THEN
		SET error_code = 1;
    ELSEIF post_count + comment_count + reply_count = 0 THEN
		SET error_code = 2;
	ELSEIF post_count + comment_count + reply_count > 1 THEN
		SET error_code = 3;
    ELSE
        DELETE FROM content_react
			WHERE content_react.content_id = content_id AND content_react.reacting_person_id = reacting_person_id;
        SET error_code = 0;
    END IF;
END$$
DELIMITER ;

-- CALL DeleteReaction(0, 10216646959432839, @error_code);
-- SELECT @error_code;
-- CALL DeleteReaction(1217805638231620, 0, @error_code);
-- SELECT @error_code;
-- CALL DeleteReaction(1217805638231620, 10216646959432839, @error_code);
-- SELECT @error_code;
-- CALL DeleteReaction(1217805638231620, 10216646959432839, @error_code);
-- SELECT @error_code;
