# Some set up for the application 

from flask import Flask
from flaskext.mysql import MySQL
#from config import *

# create a MySQL object that we will use in other parts of the API
db = MySQL()

def create_app():
    app = Flask(__name__)
    
    # secret key that will be used for securely signing the session 
    # cookie and can be used for any other security related needs by 
    # extensions or your application
    app.config['SECRET_KEY'] = 'secretkey123'

    # these are for the DB object to be able to connect to MySQL. 
    app.config['MYSQL_DATABASE_HOST'] = 'db'
    app.config['MYSQL_DATABASE_PORT'] = 3306
    app.config['MYSQL_DATABASE_USER'] = 'webapp'
    app.config['MYSQL_DATABASE_PASSWORD'] = open('/secrets/db_password.txt').readline()
    app.config['MYSQL_DATABASE_DB'] = 'nts_lightning_db'

    # Initialize the database object with the settings above. 
    db.init_app(app)
    
    # Import the various routes
    from src.strategy_api.strategy import strategy_blueprint
    from src.views import views_blueprint

    # Register the routes that we just imported so they can be properly handled
    app.register_blueprint(strategy_blueprint,       url_prefix='/strategy')
    app.register_blueprint(views_blueprint,          url_prefix='/')

    return app