import mysql.connector
import json
from flask import Flask, request, jsonify
from os import environ
from string import Template
from .utils.queries import groups_query, show_followed_users, show_friend, show_unfollowed_users, show_group, show_followed_groups, show_unfollowed_groups, show_user, show_reaction, show_comment, show_comment_reply

def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__)

    def connect():
        cnx = mysql.connector.connect(user=environ.get('DB_USER'), password=environ.get('DB_PASSWORD'), host=environ.get('DB_HOST'), database=environ.get('DB_NAME'), auth_plugin='mysql_native_password')
        cursor = cnx.cursor()
        return cnx, cursor

    def disconnect(cnx, cursor):
        cursor.close()
        cnx.close()

    @app.route('/user', methods = ['POST'])  
    def create_user():
        cnx, cursor = connect()
        output = {}
        request_data = request.get_json()
        in_args = [
            request_data["firstName"],
            request_data["lastName"],
            request_data["sexId"],
            request_data["email"],
            request_data["passcode"],
            0,
            0,
        ]
        out_args = cursor.callproc('CreateAccount', in_args)
        if out_args[-1] == 0:
            cnx.commit()
            output = {"data":{"userId": out_args[-2]}}
        else:
            output = {"error": out_args[-1]}

        disconnect(cnx, cursor)
        return output

    @app.route('/<uid>/profile', methods = ['GET', 'POST']) 
    def user_profile(uid): 
        cnx, cursor = connect()
        output = {}
        if request.method == 'POST':
            request_data = request.get_json()
            in_args = [
                uid,
                request_data["firstName"],
                request_data["lastName"],
                request_data["sexId"],
                request_data["email"],
                request_data["passcode"],
                0,
            ]
            out_args = cursor.callproc('ModifyAccount', in_args)
            if out_args[-1] == 0:
                cnx.commit()
                cursor.execute(Template(show_user).substitute(id=uid))
                data = {}
                for (person_id, first_name, last_name, sex_id, email, passcode) in cursor:
                    data[person_id] = {
                        "userId": person_id,
                        "firstName": first_name,
                        "lastName": last_name, 
                        "sexId": sex_id,
                        "email": email,
                        "passcode": passcode,
                    }
                output = {"data": data}
            else:
                output = {"error": out_args[-1]}
        else:
            cursor.execute(Template(show_user).substitute(id=uid))
            data = {}
            for (person_id, first_name, last_name, sex_id, email, passcode) in cursor:
                print(person_id)
                data[person_id] = {
                    "userId": person_id,
                    "firstName": first_name,
                    "lastName": last_name, 
                    "sexId": sex_id,
                    "email": email,
                    "passcode": passcode
                }
            output = {"data": data}
            
        disconnect(cnx, cursor)
        return output
    @app.route('/<uid>/posts', methods = ['GET', 'POST'])
    def posts(uid):
        cnx, cursor = connect()
        if request.method == 'POST':
            request_data = request.get_json()
            proc_result = cursor.callproc('CreatePost', [uid, request_data['groupId'], request_data['content'], 0, 0])
            cnx.commit()
            disconnect(cnx, cursor)
            return {"data": {"postId": str(proc_result[-2])}} if proc_result[-1] == 0 else {"error": proc_result[-1]}
        
        proc_args = [
            request.args.get('time'),
            uid,
            request.args.get('page'),
            '',
        ]
        proc_result = cursor.callproc('GetPosts', proc_args)
        row_headers = ['postId', 'content', 'personId', 'groupId', 'timeStamp', 'userReaction', 'reaction']
        posts = []
        for result in cursor.stored_results():
            for r in result.fetchall():
                r_json = [x for x in r]
                print(r_json)
                r_json[-1] = r_json[-1] and json.loads(r_json[-1])
                posts.append(dict(zip(row_headers, r_json)))
        data = {}
        data["latest_time_read"] = proc_result[-1]
        data["posts"] = posts
        disconnect(cnx, cursor)
        return {"data": data}
    
    @app.route('/<uid>/posts/<pid>', methods = ['POST'])
    def delete_post(uid, pid):
         cnx, cursor = connect()
         cursor.callproc('DeletePost', [pid])
         cnx.commit()
         disconnect(cnx, cursor)
         return {"data": {"postId": pid}}

    @app.route('/<uid>/<pid>/comments', methods = ['GET', 'POST'])
    def comments(uid, pid):
        cnx, cursor = connect()
        row_headers = ['commentId', 'content', 'personId', 'groupId', 'timeStamp', 'postId','userReaction', 'reaction']
        if request.method == 'POST':
            request_data = request.get_json()
            proc_result = cursor.callproc('CreatePostComment', [uid, request_data['groupId'], request_data['content'], pid, 0, 0])
            if proc_result[-1] == 0:
                cnx.commit()
                comments = []
                cursor.execute(Template(show_comment).substitute(cid=proc_result[-2]))
                for r in cursor:
                    comments.append(dict(zip(row_headers, r)))
                disconnect(cnx, cursor)
                data = {}
                data["comments"] = comments
                return {"data": data}
            disconnect(cnx, cursor)
            return {"error": proc_result[-1]}
        
        cursor.callproc('GetComments', [pid, uid, request.args.get('page')])
        comments = []
        for result in cursor.stored_results():
            for r in result.fetchall():
                r_json = [x for x in r]
                print(r_json)
                r_json[-1] = r_json[-1] and json.loads(r_json[-1])
                comments.append(dict(zip(row_headers, r_json)))
        data = {}
        data["comments"] = comments
        disconnect(cnx, cursor)
        return {"data": data}
    
    @app.route('/<uid>/<pid>/comments/<cid>', methods = ['POST'])
    def delete_post_comment(uid, pid, cid):
         cnx, cursor = connect()
         cursor.callproc('DeletePostComment', [cid])
         cnx.commit()
         disconnect(cnx, cursor)
         return {"data": {"commentId": cid}}

    @app.route('/<uid>/<pid>/<cid>/commentreplies', methods = ['GET', 'POST'])
    def reply_comment(uid, cid, pid):
        cnx, cursor = connect()
        row_headers = ['replyId', 'content', 'personId', 'groupId', 'timeStamp', 'postId', 'commentId', 'userReaction', 'reaction']
        if request.method == 'POST':
            request_data = request.get_json()
            proc_result = cursor.callproc('CreateCommentReply', [uid, request_data['groupId'], request_data['content'], pid, cid, 0, 0])
            if proc_result[-1] == 0:
                cnx.commit()
                replies = []
                cursor.execute(Template(show_comment_reply).substitute(rid=proc_result[-2]))
                for r in cursor:
                    replies.append(dict(zip(row_headers, r)))
                disconnect(cnx, cursor)
                data = {}
                data["replies"] = replies
                return {"data": data}
            disconnect(cnx, cursor)
            return {"error": proc_result[-1]}
        cursor.callproc('GetCommentReplies', [cid, uid, request.args.get('page')])
        replies = []
        for result in cursor.stored_results():
            for r in result.fetchall():
                r_json = [x for x in r]
                print(r_json)
                r_json[-1] = r_json[-1] and json.loads(r_json[-1])
                replies.append(dict(zip(row_headers, r_json)))
        data = {}
        data["replies"] = replies
        disconnect(cnx, cursor)
        return {"data": data}

    @app.route('/<uid>/<pid>/<cid>/commentreplies/<crid>', methods = ['GET', 'POST'])
    def delete_reply_comment(uid, pid, cid, crid):
         cnx, cursor = connect()
         cursor.callproc('DeleteCommentReply', [crid])
         cnx.commit()
         disconnect(cnx, cursor)

         return {"data": {"commentReplyId": crid}}


    @app.route('/<uid>/users/follow', methods = ['GET', 'POST'])
    def follow_user(uid):
        cnx, cursor = connect()
        output = {}
        if request.method == 'POST':
            friend_id = request.get_json()['id']
            result = cursor.callproc('FollowFriend', [uid, friend_id, 0])
            if result[-1] == 0:
                cnx.commit()
                cursor.execute(Template(show_friend).substitute(id=friend_id))
                data = {}
                for (person_id, first_name, last_name) in cursor:
                    data[person_id] = {
                        "userId": person_id,
                        "firstName": first_name,
                        "lastName": last_name, 
                        }
                output = {"data": data} 
            else:
                output = {"error": result[-1]}
        else:
            data = {}
            cursor.execute(Template(show_followed_users).substitute(id=uid))
            for (person_id, first_name, last_name) in cursor:
                data[person_id] = {
                    "userId": person_id,
                    "firstName": first_name,
                    "lastName": last_name, 
                    }
            output = {"data" : data}
        disconnect(cnx, cursor)
        return output

    @app.route('/<uid>/users/unfollow', methods = ['GET','POST'])
    def unfollow_user(uid):
        cnx, cursor = connect()
        output = {}
        if request.method == 'POST':
            friend_id = request.get_json()['id']
            result = cursor.callproc('UnfollowFriend', [uid, friend_id, 0])
            if result[-1] == 0:
                cnx.commit()
                data = {
                    "userId": friend_id
                }
                output = {"data": data}
            else:
                output = {"error": result[-1]}
        else:
            data = {}
            cursor.execute(Template(show_unfollowed_users).substitute(id=uid))
            for (person_id, first_name, last_name) in cursor:
                data[person_id] = {
                    "userId": person_id,
                    "firstName": first_name,
                    "lastName": last_name, 
                    }
            output = {"data" : data}
        disconnect(cnx, cursor)
        return output

    @app.route('/<uid>/groups/follow', methods = ['GET','POST'])
    def follow_group(uid):
        cnx, cursor = connect()
        output = {}
        if request.method == 'POST':
            group_id = request.get_json()['id']
            result = cursor.callproc('FollowGroup', [uid, group_id, 0])
            if result[-1] == 0:
                cnx.commit()
                cursor.execute(Template(show_group).substitute(id=group_id))
                data = {}
                for (group_id, group_name) in cursor:
                    data[group_id] = {
                        "groupId": group_id,
                        "groupName": group_name,
                    }
                output = {"data": data} 
            else:
                output = {"error": result[-1]}
        else:
            data = {}
            cursor.execute(Template(show_followed_groups).substitute(id=uid))
            for (group_id, group_name) in cursor:
                data[group_id] = {
                    "groupId": group_id,
                    "groupName": group_name,
                }
            output = {"data" : data}
        disconnect(cnx, cursor)
        return output

    @app.route('/<uid>/groups/unfollow', methods = ['POST', 'GET'])
    def unfollow_group(uid):
        cnx, cursor = connect()
        output = {}
        if request.method == 'POST':
            group_id = request.get_json()['id']
            result = cursor.callproc('UnfollowGroup', [uid, group_id, 0])
            if result[-1] == 0:
                cnx.commit()
                data = {
                    "groupId": group_id
                }
                output = {"data": data}
            else:
                output = {"error": result[-1]}
        else:
            data = {}
            cursor.execute(Template(show_unfollowed_groups).substitute(id=uid))
            for (group_id, group_name) in cursor:
                data[group_id] = {
                    "groupId": group_id,
                    "groupName": group_name,
                }
            output = {"data" : data}
        disconnect(cnx, cursor)
        return output

    @app.route('/<uid>/content/<cid>/react', methods = ['POST'])
    def react(uid, cid):
        cnx, cursor = connect()
        output = {}
        req_data = request.get_json()
        if req_data['reactionType'] == None:
            result = cursor.callproc('DeleteReaction', [cid, uid, 0])
            cnx.commit()
            output = {"data": {"contentId": cid}} if result[-1] == 0 else {"error": result[-1]}
        else:
            result = cursor.callproc('CreateReaction', [cid, uid, req_data["reactionType"], 0])
            if result[-1] == 0:
                cnx.commit()
                cursor.execute(Template(show_reaction).substitute(pid=uid, cid=cid))
                data = {}
                for (content_id,reacting_person_id,reaction_type) in cursor:
                    data[content_id] = {
                        "personId": reacting_person_id,
                        "contentId": content_id,
                        "reactionType": reaction_type
                    }
                output = {"data": data}
            else:
                output  = {"error": result[-1]}
        disconnect(cnx, cursor)
        return output
    return app

