# Some set up for the application 

from flask import Flask
import pymysql
from config import *

# create a DB object that we will use in other parts of the API
db = pymysql.connect(host=RDS_HOSTNAME, user=RDS_USER, password=RDS_PASSWORD, database='nts_lightning_db_v2', autocommit=True)

def create_app():
    app = Flask(__name__)
    
    # secret key that will be used for securely signing the session 
    # cookie and can be used for any other security related needs by 
    # extensions or your application
    app.config['SECRET_KEY'] = SECRET_KEY
    
    # Import the various routes
    from src.strategy_api.strategy import strategy_blueprint
    from src.views import views_blueprint

    # Register the routes that we just imported so they can be properly handled
    app.register_blueprint(strategy_blueprint,       url_prefix='/strategy')
    app.register_blueprint(views_blueprint,          url_prefix='/')

    return app