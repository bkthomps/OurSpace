USE our_space;

DROP PROCEDURE IF EXISTS GetPosts;
DELIMITER $$
CREATE PROCEDURE GetPosts(
	IN last_time_read VARCHAR(20),
    IN person_id  BIGINT,
    IN page_num INT,
    OUT latest_time_read VARCHAR(20)
)
BEGIN
	DECLARE row_num INT DEFAULT page_num * 20;
    CREATE TEMPORARY TABLE Filtered
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
    
    SELECT MAX(time_stamp) INTO latest_time_read from Filtered;
    
    SELECT  CAST(post_id as CHAR) as postId, 
			content,
            CAST(Filtered.person_id as CHAR) as personId,
            CAST(group_id as CHAR) as groupId, 
            time_stamp as timeStamp,
			(SELECT reaction_type FROM our_space.content_react
            WHERE content_react.content_id = Filtered.post_id 
            AND content_react.reacting_person_id = person_id) AS user_reaction,
            (SELECT IFNULL(JSON_OBJECTAGG(reaction_type, reactions), '')
            FROM 
				(SELECT reaction_type, COUNT(content_react.content_id) as reactions
                FROM our_space.content_react 
                WHERE content_react.content_id = Filtered.post_id
                GROUP BY reaction_type) as A)
			AS reaction
    FROM Filtered LIMIT row_num, 20;
    DROP TEMPORARY TABLE Filtered;
END$$
DELIMITER ;
-- CALL GetPosts('0', 544889637987,2, @lasttime);

DROP PROCEDURE IF EXISTS GetComments;
DELIMITER $$
CREATE PROCEDURE GetComments(
    IN post_id  BIGINT,
    IN person_id BIGINT,
    IN page_num INT
)
BEGIN
	DECLARE row_num INT DEFAULT page_num * 5;
    CREATE TEMPORARY TABLE Filtered 
    SELECT * from our_space.post_comment WHERE post_comment.post_id = post_id order by post_comment.time_stamp desc;
    
    SELECT  CAST(comment_id as CHAR) as commentId, 
			content,
            CAST(Filtered.person_id as CHAR) as personId,
            CAST(group_id as CHAR) as groupId, 
            time_stamp as timeStamp,
            CAST(Filtered.post_id as CHAR) as postId,
            (SELECT reaction_type FROM our_space.content_react
            WHERE content_react.content_id = Filtered.comment_id 
            AND content_react.reacting_person_id = person_id) AS user_reaction,
            (SELECT JSON_OBJECTAGG(reaction_type, reactions) as reactions
            FROM 
				(SELECT reaction_type, COUNT(content_react.content_id) as reactions
                FROM our_space.content_react 
                WHERE content_react.content_id = Filtered.comment_id
                GROUP BY reaction_type) as A)
			AS reaction
    FROM Filtered LIMIT row_num, 5;
    DROP TEMPORARY TABLE Filtered;
END$$
DELIMITER ;

-- CALL GetComments(227177443961116, 10209758438138726, 0);

DROP PROCEDURE IF EXISTS GetCommentReplies;
DELIMITER $$
CREATE PROCEDURE GetCommentReplies(
    IN comment_id  BIGINT,
    IN person_id BIGINT, 
    IN page_num INT
)
BEGIN
	DECLARE row_num INT DEFAULT page_num * 5;
    CREATE TEMPORARY TABLE Filtered 
    select * from our_space.comment_reply where comment_reply.comment_id = comment_id order by comment_reply.time_stamp desc;
    
    SELECT  CAST(reply_id as CHAR) as replyId, 
			content,
            CAST(Filtered.person_id as CHAR) as personId,
            CAST(group_id as CHAR) as groupId, 
            time_stamp as timeStamp,
            CAST(Filtered.post_id as CHAR) as postId,
            CAST(Filtered.comment_id as CHAR) as commentId,
            (SELECT reaction_type FROM our_space.content_react
            WHERE content_react.content_id = Filtered.reply_id
            AND content_react.reacting_person_id = person_id) AS user_reaction,
            (SELECT JSON_OBJECTAGG(reaction_type, reactions) as reactions
            FROM 
				(SELECT reaction_type, COUNT(content_react.content_id) as reactions
                FROM our_space.content_react 
                WHERE content_react.content_id = Filtered.reply_id
                GROUP BY reaction_type) as A)
			AS reaction
    FROM Filtered LIMIT row_num, 5;
    DROP TEMPORARY TABLE Filtered;
END$$
DELIMITER ;
-- CALL GetCommentReplies(1217808841564633,10209758438138726, 0);
