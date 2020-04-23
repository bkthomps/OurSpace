groups_query = 'select * from our_space.`groups`'
show_unfollowed_users =  'select person_id, first_name, last_name FROM our_space.person where not exists (select * from our_space.following_friends where first_person_id=$id and second_person_id = person_id) limit 100;'
show_followed_users = 'select distinct second_person_id as person_id, first_name, last_name FROM our_space.following_friends inner join our_space.person on person_id=second_person_id where first_person_id = $id;'
show_friend = 'select person_id, first_name, last_name from our_space.person where person_id=$id;'

show_group = 'select group_id, group_name from our_space.`groups` where group_id=$id;'
show_unfollowed_groups = 'select group_id, group_name FROM our_space.`groups` where not exists (select * from our_space.following_groups where person_id=$id and group_id = `groups`.group_id) limit 100;'
show_followed_groups = 'select distinct group_id, group_name from our_space.following_groups inner join our_space.`groups` using(group_id) where person_id = $id;'

show_user = 'select * from our_space.person where person_id = $id;'

show_reaction = 'select * from our_space.content_react where reacting_person_id = $pid and content_id = $cid;' 