USE our_space;

DROP PROCEDURE IF EXISTS GetPosts;
DELIMITER $$
CREATE PROCEDURE GetPosts(
	IN last_time_read VARCHAR(20),
    IN person_id  BIGINT,
    OUT latest_time_read VARCHAR(20)
)
BEGIN
    CREATE TEMPORARY TABLE FilteredPosts
	WITH FollowedFriends AS 
    (SELECT distinct second_person_id as friend_id 
    from our_space.following_friends 
    where following_friends.first_person_id = person_id),
    FollowedGroups AS 
    (SELECT distinct group_id
    from our_space.following_groups
    where following_groups.person_id = person_id)
    SELECT * FROM our_space.post where time_stamp > last_time_read and post.person_id != person_id
    and (post.person_id IN (SELECT friend_id FROM FollowedFriends) 
    or post.group_id IN (SELECT group_id FROM FollowedGroups)) order by post.time_stamp desc;
    SELECT MAX(time_stamp) INTO latest_time_read from FilteredPosts;
    SELECT post_id, content, FilteredPosts.person_id, group_id, time_stamp FROM FilteredPosts;
    DROP TEMPORARY TABLE FilteredPosts;
END$$
DELIMITER ;

