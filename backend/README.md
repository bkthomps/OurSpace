PROJECT SETUP GUIDE
1. Make sure you have python3 at least 3.6 installed
2. Make sure you have pip installed
3. Create your environment
   - navigate to OurSpace/backend
   $ python3 -m venv venv
   $ . venv/bin/activate
4. Now install flask
   $ pip install flask
5. Install pipenv
   $ pip install pipenv
6. Install python-dotenv
   $ pipenv install flask python-dotenv
   $ pipenv shell
7. To use MySQLdb we need to download the offical connector
   https://dev.mysql.com/doc/connector-python/en/connector-python-installation.html
   After you've downloaded the connector you need to install the python3 connector
   $ pip3 install mysql-connector-python
8. Copy the .config_env file into a .env file and set your db settings
9. Run
   $ flask run

RUNNING THE PROJECT GUIDE
1. Make sure you activate the virtual environment 
$ source venv/bin/activate
2. Run the project
   $ flask run
