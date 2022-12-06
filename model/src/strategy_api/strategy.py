from flask import Blueprint, jsonify
from src import db
from src.db_model import DBModel

strategy_blueprint = Blueprint('strategy_blueprint', __name__)

db_model = DBModel()

# TODO: Make generalized SQL methods in a sql-model file
# TODO: Redo endpoints to hit DB and do logic in python, returning as a JSON

@strategy_blueprint.route('/get_strategy_status/<strategy>')
def get_strategy_status(strategy):
    """
    Method to get the current status of a strategy. The status represents a snapshot of the strategy's current state.
    Output will come in the format:
    ---------------------------------------
    <Strategy Name>
    Current Active Trades: <Count of All Open Trades>
    Current Capital Usage: <Aggregate Value of All Open Trades>
    txt: <>
    (?) Error Status: <Count of Errors on Error Log>
    Running On: <AWS EC2 HostName>
    ---------------------------------------
    """
    return db_model.get_strategy_info(strategy)

@strategy_blueprint.route('/get_strategy_statistics/<strategy>')
def get_strategy_statistics(strategy):
    """
    Method to get a strategy's performance stats. Stats will be exclusive of all open trades.
    Output will come in the format:
    ---------------------------------------
    <Strategy Name>
    Cumulative P/L: <Overall P/L of strategy>
    YTD P/L: <Cululative P/L since Jan 1, (curYear)>
    Average Annual % Return: <Average Anualized Rate of Return (calendar days)>
    Average Daily % Return: <Average Daily Rate of Return (trading days)>
    Average Trades per Day: <Average Count of Trades per Day (trading days)>
    Sharpe: <Cumulative Sharpe Ratio of Strategy>
    Launch Date: <First Date of Live Trading>
    ---------------------------------------
    """
    pass

@strategy_blueprint.route('/get_strategy_hist_trades/<strategy>-<lookback>')
def get_strategy_hist_trades(strategy, lookback):
    """
    Gets all historical trades information from the specified strategy to the specified number of lookback days, where...
    Strategy: Name of the strategy to get historical trade information from
        - Format: Identical to format in DB (i.e. CamelCase proper)
    Lookback: Limit of calendar days to request historical trade information for

    ex.) get_strategy_hist_trades(LongGME, 69)
         - Returns a JSON of all historical trades and their corresponding attributes for the last 69 calendar days from the LongGME strategy.
         - JSON is inclusive of the current calendar day but exclusive of all open trades (not historical)
    """
    pass

@strategy_blueprint.route('/get_strategy_open_trades/<strategy>')
def get_strategy_open_trades(strategy):
    """
    Gets all open trades information from the specified strategy, where...
    Strategy: Name of the strategy to get historical trade information from
        - Format: Identical to format in DB (i.e. CamelCase proper)

    ex.) get_strategy_open_trades(LunchBreakReversion)
         - Returns a JSON of all open trades and their corresponding attributes from the LunchBreakReversion strategy. 
         - JSON is inclusive of every trade that has a non-zero net open value (aggregate qty of all legs != 0)
    """
    pass