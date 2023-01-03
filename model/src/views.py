from flask import Blueprint
from src import db

views_blueprint = Blueprint('views', __name__)

# This is a base route
# we simply return a string.  
@views_blueprint.route('/')
def home():
    return "<h1>Login Screen</h1>"

# This is a sample route for the /test URI.  
# as above, it just returns a simple string. 
@views_blueprint.route('/test')
def tester():
    return "<h1>this is a test!</h1>"

# This is a hack to reload broken database connection
@views_blueprint.route('/reload')
def reloader():
    db.ping();
    return "<h1>reload success</h1>"