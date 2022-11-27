# import the Flask framework
from flask import Flask, jsonify
from flaskext.mysql import MySQL
import secrets

# create a flask object
app = Flask(__name__)

# add db config variables to the app object
app.config['MYSQL_DATABASE_HOST'] = 'db'
app.config['MYSQL_DATABASE_PORT'] = 3306
app.config['MYSQL_DATABASE_USER'] = 'admin'
app.config['MYSQL_DATABASE_PASSWORD'] = secrets.DOCKER_DB_PASSWORD
app.config['MYSQL_DATABASE_DB'] = 'nts-lightning-db'

# create the MySQL object and connect it to the 
# Flask app object
global DB_CONNECTION
DB_CONNECTION = MySQL()
DB_CONNECTION.init_app(app)

# import the strategy blueprint
from strategy_api.strategy import strategy_blueprint

# register the blueprints we created with the current Flask app object.
app.register_blueprint(strategy_blueprint, url_prefix='/strat')

@app.route("/")
def home_page():
    """
    TODO: Make this a login page that requests credentials.
    """
    return f'<h1>nts lightning flask db demo</h1>'

@app.route("/test_db")
def test_db():
    cur = DB_CONNECTION.get_db().cursor()
    cur.execute('select * from strategy')
    col_headers = [x[0] for x in cur.description]
    json_data = []
    the_data = cur.fetchall()
    for row in the_data:
        json_data.append(dict(zip(col_headers, row)))
    return jsonify(json_data)


# If this file is being run directly, then run the application 
# via the app object. 
# debug = True will provide helpful debugging information and 
#   allow hot reloading of the source code as you make edits and 
#   save the files. 
if __name__ == '__main__': 
    app.run(debug = True, host = '0.0.0.0', port = 4000)