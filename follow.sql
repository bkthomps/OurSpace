USE our_space;

DROP PROCEDURE IF EXISTS FollowFriend;
DELIMITER $$
CREATE PROCEDURE FollowFriend(
    IN person_id   BIGINT,
    IN friend_id   BIGINT,
    OUT error_code INT
)
BEGIN
    DECLARE person_count INT;
    DECLARE friend_count INT;
    DECLARE relation_count INT;
    SELECT COUNT(person.person_id) INTO person_count FROM person WHERE person.person_id = person_id;
    SELECT COUNT(person.person_id) INTO friend_count FROM person WHERE person.person_id = friend_id;
    SELECT COUNT(*)
		INTO relation_count
        FROM following_friends
        WHERE first_person_id = person_id AND second_person_id = friend_id;
	IF person_count = 0 THEN
		SET error_code = 1;
	ELSEIF friend_count = 0 THEN
		SET error_code = 2;
	ELSEIF relation_count != 0 THEN
		SET error_code = 3;
	ELSEIF person_id = friend_id THEN
		SET error_code = 4;
	ELSE
		INSERT INTO following_friends VALUES (person_id, friend_id);
		SET error_code = 0;
    END IF;
END$$
DELIMITER ;

-- CALL FollowFriend(182607169204212, 0, @error_code);
-- SELECT @error_code;
-- CALL FollowFriend(182607169204212, 182607169204212, @error_code);
-- SELECT @error_code;
-- CALL FollowFriend(182607169204212, 10210477553519846, @error_code);
-- SELECT @error_code;
-- CALL FollowFriend(182607169204212, 10210477553519846, @error_code);
-- SELECT @error_code;

DROP PROCEDURE IF EXISTS UnfollowFriend;
DELIMITER $$
CREATE PROCEDURE UnfollowFriend(
    IN person_id   BIGINT,
    IN friend_id   BIGINT,
    OUT error_code INT
)
BEGIN
    DECLARE relation_count INT;
    SELECT COUNT(*)
		INTO relation_count
        FROM following_friends
        WHERE first_person_id = person_id AND second_person_id = friend_id;
	IF person_id = friend_id THEN
		SET error_code = 1;
	ELSEIF relation_count = 0 THEN
		SET error_code = 2;
	ELSE
		DELETE FROM following_friends WHERE first_person_id = person_id AND second_person_id = friend_id;
		SET error_code = 0;
    END IF;
END$$
DELIMITER ;

-- CALL UnfollowFriend(182607169204212, 182607169204212, @error_code);
-- SELECT @error_code;
-- CALL UnfollowFriend(182607169204212, 10210477553519846, @error_code);
-- SELECT @error_code;
-- CALL UnfollowFriend(182607169204212, 10210477553519846, @error_code);
-- SELECT @error_code;

DROP PROCEDURE IF EXISTS FollowGroup;
DELIMITER $$
CREATE PROCEDURE FollowGroup(
    IN person_id   BIGINT,
    IN group_id    BIGINT,
    OUT error_code INT
)
BEGIN
    DECLARE person_count INT;
    DECLARE group_count INT;
    DECLARE relation_count INT;
    SELECT COUNT(person.person_id) INTO person_count FROM person WHERE person.person_id = person_id;
    SELECT COUNT(groups.group_id) INTO group_count FROM groups WHERE groups.group_id = group_id;
    SELECT COUNT(*)
		INTO relation_count
        FROM following_groups
        WHERE following_groups.person_id = person_id AND following_groups.group_id = group_id;
	IF person_count = 0 THEN
		SET error_code = 1;
	ELSEIF group_count = 0 THEN
		SET error_code = 2;
	ELSEIF relation_count != 0 THEN
		SET error_code = 3;
	ELSE
		INSERT INTO following_groups VALUES (person_id, group_id);
		SET error_code = 0;
    END IF;
END$$
DELIMITER ;

-- CALL FollowGroup(182607169204212, 0, @error_code);
-- SELECT @error_code;
-- CALL FollowGroup(182607169204212, 25160801076, @error_code);
-- SELECT @error_code;
-- CALL FollowGroup(182607169204212, 25160801076, @error_code);
-- SELECT @error_code;

DROP PROCEDURE IF EXISTS UnfollowGroup;
DELIMITER $$
CREATE PROCEDURE UnfollowGroup(
    IN person_id   BIGINT,
    IN group_id    BIGINT,
    OUT error_code INT
)
BEGIN
    DECLARE relation_count INT;
    SELECT COUNT(*)
		INTO relation_count
        FROM following_groups
        WHERE following_groups.person_id = person_id AND following_groups.group_id = group_id;
	IF relation_count = 0 THEN
		SET error_code = 1;
	ELSE
		DELETE FROM following_groups
			WHERE following_groups.person_id = person_id AND following_groups.group_id = group_id;
		SET error_code = 0;
    END IF;
END$$
DELIMITER ;

-- CALL UnfollowGroup(182607169204212, 0, @error_code);
-- SELECT @error_code;
-- CALL UnfollowGroup(182607169204212, 25160801076, @error_code);
-- SELECT @error_code;
-- CALL UnfollowGroup(182607169204212, 25160801076, @error_code);
-- SELECT @error_code;
