from flask import Blueprint, jsonify, request
from src import db
from src.db_model import DBModel
import pandas as pd

portfolio_blueprint = Blueprint('portfolio_blueprint', __name__)

db_model = DBModel()

"""
Portfolio Page:

Stores all routes to get information about the portfolio in its entirety.
"""

@portfolio_blueprint.route('/get_active_strategies')
def get_active_strategies():  # <-- Status: Passing All Tests
    """
    Method to get a list of all active strategies. An active strategy is defined as one that is currently running on an EC2.
    Returns all attributes of the strategy table.
    """
    try:
        acts = db_model.get_active_strategies()
        return acts
    except Exception as e:
        return f'Error: {e}'

@portfolio_blueprint.route('/get_daily_pnl')
def get_daily_pnl():  # <-- Status: Passing All Tests
    """
    Method to get all daily P&L across the entire portfolio.
    Returns a JSON of the following format:
    ---------------------------------------
    {
        "Date": <Date>,
        "P&L": <P&L on Date>
    }
    ---------------------------------------
    """
    try:
        dpnl = db_model.get_daily_pnl()
        return dpnl
    except Exception as e:
        return f'Error: {e}'

# TODO
@portfolio_blueprint.route('/get_top_of_book')
def get_top_of_book():
    """
    Method to return the top of the book for all active strategies. Includes all open positions.
    Output will come in the format:
    ---------------------------------------
    {
        "capital_usage": <Aggregate Value of All Open Trades>,
        "active_trades": <Count of All Open Trades>,
        ...
    """
    try:
        tob = db_model.get_top_of_book()
        return tob
    except Exception as e:
        return f'Error: {e}'