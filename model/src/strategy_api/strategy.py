from flask import Blueprint, jsonify, request
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
    return db_model.get_active_strategies()

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

    return db_model.get_daily_pnl()

### STRATEGY PAGE ###

@strategy_blueprint.route('/get_strategy_status')
def get_strategy_status():
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
    try:
        # BREAKPOINT!!
        strategy = request.args.get('strategy')
        strategy_info = db_model.get_strategy_info(strategy)
        s_name = strategy
        try:
            s_id = strategy_info[0]['strategy_id']
        except Exception as e:
            s_id = 0
        s_running_on = 'unknown'

        trades = db_model.get_open_trades(strategy)
        s_active_trades = len(trades)
        s_capital_usage = 0
        # BREAKPOINT!!
        try:
            for i in range(len(trades)):
                s_capital_usage += trades[i]['capital_usage']
        except Exception as e:
            s_capital_usage = 0

        return jsonify(strategy_name=s_name,
        strategy_id=s_id,
        active_trades=s_active_trades,
        capital_usage=s_capital_usage,
            running_on=s_running_on)
    
    except Exception as e:
        return f'Error: {e}'

@strategy_blueprint.route('/get_strategy_hist_trades')
def get_strategy_hist_trades():
    """
    Gets all historical trades information from the specified strategy to the specified number of lookback months, where...
    Strategy: Name of the strategy to get historical trade information from
        - Format: Identical to format in DB (i.e. CamelCase proper)
    Lookback: Limit of calendar months to request historical trade information for

    ex.) get_strategy_hist_trades(LongGME, 6)
         - Returns a JSON of all historical trades and their corresponding attributes for the last 6 calendar months from the LongGME strategy.
         - JSON is inclusive of the current calendar day but exclusive of all open trades (not historical)
    """
    try:
        strategy = request.args.get('strategy')
        lookback = request.args.get('lookback')
        # Potentially convert the type to an integer
        if type(lookback) == str: lookback = int(lookback)

        return db_model.get_historical_trades(strategy, lookback)
    except Exception as e:
        return f'Error: {e}'

@strategy_blueprint.route('/get_strategy_open_trades')
def get_strategy_open_trades():
    """
    Gets all open trades information from the specified strategy, where...
    Strategy: Name of the strategy to get historical trade information from
        - Format: Identical to format in DB (i.e. CamelCase proper)

    ex.) get_strategy_open_trades(LunchBreakReversion)
         - Returns a JSON of all open trades and their corresponding attributes from the LunchBreakReversion strategy. 
         - JSON is inclusive of every trade that has a non-zero net open value (aggregate qty of all legs != 0)
    """
    try:
        strategy = request.args.get('strategy')

        return db_model.get_open_trades(strategy)
    except Exception as e:
        return f'Error: {e}'


@strategy_blueprint.route('/get_strategy_statistics')
def get_strategy_statistics():
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
    ---------------------------------------
    """

    try:
        strategy = request.args.get('strategy')
        return db_model.get_strategy_statistics(strategy)
    except Exception as e:
        return f'Error: {e}'

@strategy_blueprint.route('/get_strategy_pnl')
def get_strategy_pnl():
    """
    Method to get all daily P&L across the entire strategy through all time.
    Returns a JSON of the following format:
    ---------------------------------------
    {
        "Date": <Date>,
        "P&L": <P&L on Date>
    }
    ---------------------------------------
    """
    try:
        strategy = request.args.get('strategy')
        json_data = db_model.get_strategy_pnl(strategy)
        df = pd.DataFrame(json_data)
        df['Date'] = pd.to_datetime(df['Date'])
        df = df.set_index('Date')
        df = df.groupby(pd.Grouper(freq='D')).sum()
        df = df.reset_index()
        df['Date'] = df['Date'].dt.strftime('%Y-%m-%d')
        col_headers = [x for x in df.columns]
        json_data = []
        for entry in df.values:
            json_data.append(dict(zip(col_headers, entry)))
    except Exception as e:
        return f'Error: {e}'
        
    # Error with pd.Dataframe - need to pass a list of lists not a list of dicts
    return json_data