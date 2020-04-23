import mysql.connector
from flask import Flask, request
from os import environ
from string import Template
from .utils.queries import groups_query, show_followed_users, show_friend, show_unfollowed_users, show_group, show_followed_groups, show_unfollowed_groups, show_user, show_reaction

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
    # @app.route('/<uid>/posts', methods = ['GET', 'POST'])
    # def posts(uid):
    #     if request.method == 'POST':
        

    # @app.route('/<uid>/<pid>/comments', methods = ['GET', 'POST'])
    # def comments(uid, pid):

    # @app.route('/<uid>/<cid>/commentreplies', methods = ['GET', 'POST'])
    # def reply_comment(uid, cid):


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

