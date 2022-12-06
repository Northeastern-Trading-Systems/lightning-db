from flask import Blueprint

views_blueprint = Blueprint('views', __name__)

# This is a base route
# we simply return a string.  
@views_blueprint.route('/')
def home():
    return ('<h1>Login Screen</h1>')

# This is a sample route for the /test URI.  
# as above, it just returns a simple string. 
@views_blueprint.route('/test')
def tester():
    return "<h1>this is a test!</h1>"