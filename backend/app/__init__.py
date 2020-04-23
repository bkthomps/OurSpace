import mysql.connector
from flask import Flask, request
from os import environ
from string import Template
from .utils.queries import groups_query, show_followed_users, show_friend, show_unfollowed_users

def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__)

    # user viewing and following users 
    @app.route('/<uid>/users/follow', methods = ['GET', 'POST'])
    def follow_user(uid):
        cnx = mysql.connector.connect(user=environ.get('DB_USER'), password=environ.get('DB_PASSWORD'), host=environ.get('DB_HOST'), database=environ.get('DB_NAME'), auth_plugin='mysql_native_password')
        cursor = cnx.cursor()
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
        cursor.close()
        cnx.close()
        return output

    # # user viewing and unfollowing friends
    @app.route('/<uid>/users/unfollow', methods = ['GET','POST'])
    def unfollow_user(uid):
        cnx = mysql.connector.connect(user=environ.get('DB_USER'), password=environ.get('DB_PASSWORD'), host=environ.get('DB_HOST'), database=environ.get('DB_NAME'), auth_plugin='mysql_native_password')
        cursor = cnx.cursor()
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
        cursor.close()
        cnx.close()
        return output

 
    return app