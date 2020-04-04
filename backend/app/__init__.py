import mysql.connector
from flask import Flask
from os import environ
from .utils.queries import groups_query

def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__)

    # a simple page that says hello
    @app.route('/groups')
    def get_groups():
        cnx = mysql.connector.connect(user=environ.get('DB_USER'), password=environ.get('DB_PASSWORD'), host=environ.get('DB_HOST'), database=environ.get('DB_NAME'), auth_plugin='mysql_native_password')
        cursor = cnx.cursor()
        cursor.execute(groups_query)
        output = {}
        for (group_id, group_name) in cursor:
            output[group_id] = group_name
        cursor.close()
        cnx.close()
        return {
            "groups": output
        }

    return app