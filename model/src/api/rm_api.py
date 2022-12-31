from flask import Blueprint, jsonify, request, make_response
from src import db
from src.db_model import DBModel
import pandas as pd

rm_blueprint = Blueprint('rm_blueprint', __name__)

db_model = DBModel()

"""
Risk Management Page:

Stores all routes to get risk metrics regarding current and historical portfolio states.
"""

# TODO
@rm_blueprint.route('/get_port_risk_metrics')
def get_port_risk_metrics():
    """
    Returns aggregated risk metrics for all active strategies across the entire portfolio.
    Output will come in the format:
    ---------------------------------------
    {
        "VaR": <Value at Risk>,
        "ES": <Expected Shortfall>,
        "MaxDD": <Maximum Drawdown>,
        "MaxDDDate": <Date of Maximum Drawdown>,
        ...
    }
    """
    
    return make_response('Not Implemented Yet', 200)

# TODO
@rm_blueprint.route('/get_strategy_risk_metrics')
def get_strategy_risk_metrics():
    """
    Returns risk metrics for a particular strategy.
    """
    # First, get the strategy from the request
    try:
        strategy = request.args.get('strategy')
        if db_model.strategy_exists(strategy) == False:
            return make_response(f'Error: Strategy {strategy} does not exist.', 400)
    except Exception as e:
        return make_response(f'Error: {e}', 500)

    return make_response('Not Implemented Yet', 200)
