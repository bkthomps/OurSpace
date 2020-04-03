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
7. Install flask-mysql
   $ pip install flask-mysql
8. Run
   flask run

note: if you run into errors you probably didn't activate ur venv so 
$ source venv/bin/activate
