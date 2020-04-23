USE our_space;

DROP PROCEDURE IF EXISTS CreatePost;
DELIMITER $$
CREATE PROCEDURE CreatePost(
    IN person_id   BIGINT,
    IN group_id    BIGINT,
    IN content     VARCHAR(15000),
    OUT post_id    BIGINT,
    OUT error_code INT
)
BEGIN
    DECLARE current_post_id BIGINT;
	DECLARE person_count INT;
    DECLARE group_count INT;
	SELECT MAX(id) + 1
    INTO current_post_id
    FROM (
		SELECT MAX(post_id) AS id FROM post
        UNION SELECT MAX(comment_id) AS id FROM post_comment
        UNION SELECT MAX(reply_id) AS id FROM comment_reply
    ) A;
    SELECT COUNT(person.person_id) INTO person_count FROM person WHERE person.person_id = person_id;
    SELECT COUNT(groups.group_id) INTO group_count FROM groups WHERE groups.group_id = group_id;
    SET post_id = 0;
    IF person_count != 1 THEN
		SET error_code = 1;
	ELSEIF group_id IS NOT NULL AND group_count != 1 THEN
		SET error_code = 2;
	ELSE
		INSERT INTO post VALUES (current_post_id, content, person_id, group_id, NOW(), 0, 0);
		SET post_id = current_post_id;
		SET error_code = 0;
    END IF;
END$$
DELIMITER ;

-- CALL CreatePost(1, 1, "Hello", @post_id, @error_code);
-- SELECT @post_id;
-- SELECT @error_code;
-- CALL CreatePost(10216646959432838, 1, "Hello", @post_id, @error_code);
-- SELECT @post_id;
-- SELECT @error_code;
-- CALL CreatePost(10216646959432838, NULL, "Hello", @post_id, @error_code);
-- SELECT @post_id;
-- SELECT @error_code;

DROP PROCEDURE IF EXISTS CreatePostComment;
DELIMITER $$
CREATE PROCEDURE CreatePostComment(
    IN person_id   BIGINT,
    IN group_id    BIGINT,
    IN content     VARCHAR(15000),
    IN post_id     BIGINT,
    OUT comment_id BIGINT,
    OUT error_code INT
)
BEGIN
    DECLARE current_comment_id BIGINT;
	DECLARE person_count INT;
    DECLARE group_count INT;
    DECLARE post_count INT;
	SELECT MAX(id) + 1
    INTO current_comment_id
    FROM (
		SELECT MAX(post_id) AS id FROM post
        UNION SELECT MAX(comment_id) AS id FROM post_comment
        UNION SELECT MAX(reply_id) AS id FROM comment_reply
    ) A;
    SELECT COUNT(person.person_id) INTO person_count FROM person WHERE person.person_id = person_id;
    SELECT COUNT(groups.group_id) INTO group_count FROM groups WHERE groups.group_id = group_id;
    SELECT COUNT(post.post_id) INTO post_count FROM post WHERE post.post_id = post_id;
    SET comment_id = 0;
    IF person_count != 1 THEN
		SET error_code = 1;
	ELSEIF group_id IS NOT NULL AND group_count != 1 THEN
		SET error_code = 2;
	ELSEIF post_count != 1 THEN
		SET error_code = 3;
	ELSE
		INSERT INTO post_comment VALUES (current_comment_id, content, person_id, group_id, NOW(), post_id);
		SET comment_id = current_comment_id;
		SET error_code = 0;
    END IF;
END$$
DELIMITER ;

-- CALL CreatePostComment(1, 1, "Hello", 1, @comment_id, @error_code);
-- SELECT @comment_id;
-- SELECT @error_code;
-- CALL CreatePostComment(10216646959432838, 1, "Hello", 1, @comment_id, @error_code);
-- SELECT @comment_id;
-- SELECT @error_code;
-- CALL CreatePostComment(10216646959432838, NULL, "Hello", 1, @comment_id, @error_code);
-- SELECT @comment_id;
-- SELECT @error_code;
-- CALL CreatePostComment(10216646959432838, NULL, "Hello", 10155755392661078, @comment_id, @error_code);
-- SELECT @comment_id;
-- SELECT @error_code;

DROP PROCEDURE IF EXISTS CreateCommentReply;
DELIMITER $$
CREATE PROCEDURE CreateCommentReply(
    IN person_id   BIGINT,
    IN group_id    BIGINT,
    IN content     VARCHAR(15000),
    IN post_id     BIGINT,
    IN comment_id  BIGINT,
    OUT reply_id   BIGINT,
    OUT error_code INT
)
BEGIN
    DECLARE current_reply_id BIGINT;
	DECLARE person_count INT;
    DECLARE group_count INT;
    DECLARE post_count INT;
    DECLARE comment_count INT;
	SELECT MAX(id) + 1
    INTO current_reply_id
    FROM (
		SELECT MAX(post_id) AS id FROM post
        UNION SELECT MAX(comment_id) AS id FROM post_comment
        UNION SELECT MAX(reply_id) AS id FROM comment_reply
    ) A;
    SELECT COUNT(person.person_id) INTO person_count FROM person WHERE person.person_id = person_id;
    SELECT COUNT(groups.group_id) INTO group_count FROM groups WHERE groups.group_id = group_id;
    SELECT COUNT(post.post_id) INTO post_count FROM post WHERE post.post_id = post_id;
    SELECT COUNT(post_comment.comment_id) INTO comment_count FROM post_comment WHERE post_comment.comment_id = comment_id;
    SET reply_id = 0;
    IF person_count != 1 THEN
		SET error_code = 1;
	ELSEIF group_id IS NOT NULL AND group_count != 1 THEN
		SET error_code = 2;
	ELSEIF post_count != 1 THEN
		SET error_code = 3;
	ELSEIF comment_count != 1 THEN
		SET error_code = 4;
	ELSE
		INSERT INTO comment_reply VALUES (current_reply_id, content, person_id, group_id, NOW(), post_id, comment_id);
		SET reply_id = current_reply_id;
		SET error_code = 0;
    END IF;
END$$
DELIMITER ;

CALL CreateCommentReply(1, 1, "Hello", 1, 1, @reply_id, @error_code);
SELECT @reply_id;
SELECT @error_code;
CALL CreateCommentReply(10216646959432838, 1, "Hello", 1, 1, @reply_id, @error_code);
SELECT @reply_id;
SELECT @error_code;
CALL CreateCommentReply(10216646959432838, NULL, "Hello", 1, 1, @reply_id, @error_code);
SELECT @reply_id;
SELECT @error_code;
CALL CreateCommentReply(10216646959432838, NULL, "Hello", 10155755392661078, 1, @reply_id, @error_code);
SELECT @reply_id;
SELECT @error_code;
CALL CreateCommentReply(10216646959432838, NULL, "Hello", 10155755392661078, 10155755392661079, @reply_id, @error_code);
SELECT @reply_id;
SELECT @error_code;
