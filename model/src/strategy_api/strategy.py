from flask import Blueprint, jsonify
from src import db
from src.db_model import DBModel
import pandas as pd

strategy_blueprint = Blueprint('strategy_blueprint', __name__)

db_model = DBModel()

# TODO: Make generalized SQL methods in a sql-model file
# TODO: Redo endpoints to hit DB and do logic in python, returning as a JSON

### HOME PAGE ###

@strategy_blueprint.route('/get_active_strategies')
def get_active_strategies():
    """
    Method to get a list of all active strategies. An active strategy is defined as one that is currently running on an EC2.
    Returns all attributes of the strategy table.
    """
    json_data = db_model.get_active_strategies()
    # remove all of the documentation_link and termination_date fields from the json_data
    for i in range(len(json_data)):
        del json_data[i]['termination_date']
    return json_data

@strategy_blueprint.route('/get_daily_pnl')
def get_daily_pnl():
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
    json_data = db_model.get_daily_pnl()
    df = pd.DataFrame(json_data)

    # Group the open_time by day
    df['Date'] = pd.to_datetime(df['Date'])
    df = df.set_index('Date')
    df = df.groupby(pd.Grouper(freq='D')).sum()
    df = df.reset_index()
    df['Date'] = df['Date'].dt.strftime('%Y-%m-%d')
    col_headers = [x for x in df.columns]
    json_data = []
    for entry in df.values:
        json_data.append(dict(zip(col_headers, entry)))

    return json_data

### STRATEGY PAGE ###

@strategy_blueprint.route('/get_strategy_status?Strategy=<strategy>')
def get_strategy_status(strategy):
    """
    Method to get the current status of a strategy. The status represents a snapshot of the strategy's current state.
    Output will come in the format:
    ---------------------------------------
    {
        "strategy_name": <Strategy Name>,
        "strategy_id": <Strategy ID>,
        "active_trades": <Count of All Open Trades>,
        "capital_usage": <Aggregate Value of All Open Trades>,
        "running_on": <AWS EC2 HostName>
    }
    (?) Error Status: <Count of Errors on Error Log>
    ---------------------------------------
    """
    strategy_info = db_model.get_strategy_info(strategy)
    s_name = strategy
    s_id = strategy_info[0]['strategy_id']
    s_running_on = 'unknown'

    trades = db_model.get_open_trades(strategy)
    s_active_trades = len(trades)
    s_capital_usage = 0
    for i in range(len(trades)):
        s_capital_usage += trades[i]['capital_usage']

    return jsonify(strategy_name=s_name,
     strategy_id=s_id,
      active_trades=s_active_trades,
       capital_usage=s_capital_usage,
        running_on=s_running_on)













    

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
    if lookback == '0': lookback = 0
    return db_model.get_historical_trades(strategy, lookback)

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
    return db_model.get_open_trades(strategy)

