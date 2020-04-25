USE our_space;

DROP PROCEDURE IF EXISTS CreateGroup;
DELIMITER $$
CREATE PROCEDURE CreateGroup(
    IN group_name  VARCHAR(50),
    IN person_id   BIGINT,
    OUT group_id   BIGINT,
    OUT error_code INT
)
BEGIN
	DECLARE person_count INT;
    DECLARE current_group_id BIGINT;
    SELECT COUNT(person.person_id) INTO person_count FROM person WHERE person.person_id = person_id;
    SELECT MAX(`groups`.group_id) + 1 INTO current_group_id FROM `groups`;
    SET group_id = 0;
    IF person_count != 1 THEN
        SET error_code = 1;
    ELSE
        INSERT INTO `groups` VALUES(current_group_id, group_name);
        INSERT INTO group_admin VALUES(current_group_id, person_id);
        INSERT INTO following_groups VALUES(person_id, current_group_id);
        SET group_id = current_group_id;
        SET error_code = 0;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS DeleteGroup;
DELIMITER $$
CREATE PROCEDURE DeleteGroup(
    IN group_id BIGINT
)
BEGIN
    DELETE FROM following_groups WHERE following_groups.group_id = group_id;
	DELETE FROM group_admin WHERE group_admin.group_id = group_id;
    DELETE FROM `groups` WHERE `groups`.group_id = group_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS AddAdmin;
DELIMITER $$
CREATE PROCEDURE AddAdmin(
    IN person_id   BIGINT,
    IN group_id    BIGINT,
    OUT error_code INT
)
BEGIN
    DECLARE person_count INT;
	DECLARE group_count INT;
    DECLARE user_count INT;
    SELECT COUNT(person.person_id) INTO person_count FROM person WHERE person.person_id = person_id;
    SELECT COUNT(`groups`.group_id) INTO group_count FROM `groups` WHERE `groups`.group_id = group_id;
    SELECT COUNT(*) INTO user_count FROM following_groups
            WHERE following_groups.group_id = group_id AND following_groups.person_id = person_id;
    IF person_count != 1 THEN
        SET error_code = 1;
    ELSEIF group_count != 1 THEN
        SET error_code = 2;
    ELSEIF user_count != 1 THEN
        SET error_code = 3;
    ELSE
        INSERT INTO group_admin VALUES(group_id, person_id);
        SET error_code = 0;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS RemoveAdmin;
DELIMITER $$
CREATE PROCEDURE RemoveAdmin(
    IN person_id   BIGINT,
    IN group_id    BIGINT,
    OUT error_code INT
)
BEGIN
    DECLARE person_count INT;
	DECLARE group_count INT;
    DECLARE admin_count INT;
    SELECT COUNT(person.person_id) INTO person_count FROM person WHERE person.person_id = person_id;
    SELECT COUNT(`groups`.group_id) INTO group_count FROM `groups` WHERE `groups`.group_id = group_id;
    SELECT COUNT(group_admin.person_id) INTO admin_count FROM group_admin
        WHERE group_admin.group_id = group_id;
    IF person_count != 1 THEN
        SET error_code = 1;
    ELSEIF group_count != 1 THEN
        SET error_code = 2;
    ELSEIF admin_count = 1 THEN
        SET error_code = 3;
    ELSE
        DELETE FROM group_admin WHERE group_admin.person_id = person_id and group_admin.group_id = group_id;
        SET error_code = 0;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS AddUser;
DELIMITER $$
CREATE PROCEDURE AddUser(
    IN person_id   BIGINT,
    IN group_id    BIGINT,
    OUT error_code INT
)
BEGIN
    DECLARE person_count INT;
	DECLARE group_count INT;
    DECLARE user_count INT;
    SELECT COUNT(person.person_id) INTO person_count FROM person WHERE person.person_id = person_id;
    SELECT COUNT(`groups`.group_id) INTO group_count FROM `groups` WHERE `groups`.group_id = group_id;
    SELECT COUNT(*) INTO user_count FROM following_groups
            WHERE following_groups.group_id = group_id AND following_groups.person_id = person_id;
    IF person_count != 1 THEN
        SET error_code = 1;
    ELSEIF group_count != 1 THEN
        SET error_code = 2;
    ELSEIF user_count != 0 THEN
        SET error_code = 3;
    ELSE
        INSERT INTO following_groups VALUES(person_id, group_id);
        SET error_code = 0;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS RemoveUser;
DELIMITER $$
CREATE PROCEDURE RemoveUser(
    IN person_id          BIGINT,
    IN group_id           BIGINT,
    OUT was_group_deleted INT
)
BEGIN
    DECLARE group_user_count INT;
    DELETE FROM group_admin WHERE group_admin.person_id = person_id AND group_admin.group_id = group_id;
    DELETE FROM following_groups WHERE following_groups.person_id = person_id AND following_groups.group_id = group_id;
    SELECT COUNT(*) INTO group_user_count FROM following_groups WHERE following_groups.group_id = group_id;
    IF group_user_count != 0 THEN
        SET was_group_deleted = 0;
    ELSE
        DELETE FROM `groups` WHERE `groups`.group_id = group_id;
        SET was_group_deleted = 1;
    END IF;
END$$
DELIMITER ;
