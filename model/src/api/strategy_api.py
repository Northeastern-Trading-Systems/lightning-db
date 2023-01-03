from flask import Blueprint, jsonify, request, make_response
from src import db
from src.db_model import DBModel
import pandas as pd

strategy_blueprint = Blueprint('strategy_blueprint', __name__)

db_model = DBModel()

"""
Strategy Page:

Stores all routes to get information about specific strategies.
"""

@strategy_blueprint.route('/get_strategy_status')
def get_strategy_status():  # <-- Status: Passing All Tests
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
    # Get the strategy from the request
    try:
        strategy = request.args.get('strategy')
        if strategy == '' or strategy == None: 
            return make_response('Error: No strategy specified', 400)
    except Exception as e:
        return make_response(f'Error: {e}', 500)

    # Get the strategy info and open trades from the DB
    try:
        strategy_info = db_model.get_strategy_info(strategy)
        open_trades = db_model.get_open_trades(strategy)
    except Exception as e:
        return make_response(f'Error retrieving Database Model strategy information: {e}', 500)
    
    # Get variables for the return JSON
    s_name = strategy
    try:
        s_id = strategy_info[0]['strategy_id']
    except Exception as e:
        s_id = 0
    s_running_on = 'unknown'
    s_capital_usage = 0
    try:
        for i in range(len(open_trades)):
            s_capital_usage += open_trades[i]['capital_usage']
    except Exception as e:
        s_capital_usage = 0
    try:
        s_active_trades = len(open_trades)
    except:
        s_active_trades = 0

    # Format and return as a JSON
    return make_response(jsonify(strategy_name=s_name,
        strategy_id=s_id,
        active_trades=s_active_trades,
        capital_usage=s_capital_usage,
        running_on=s_running_on), 200)

@strategy_blueprint.route('/get_strategy_statistics')
def get_strategy_statistics():  # <-- Status: Passing All Tests
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
    # Get the strategy from the request
    try:
        strategy = request.args.get('strategy')
        if db_model.strategy_exists(strategy) == False:
            return make_response(f'Error: Strategy {strategy} does not exist.', 400)
    except Exception as e:
        return make_response(f'Error: {e}', 500)

    try:
        stats = db_model.get_strategy_statistics(strategy)
        return make_response(stats, 200)
    except Exception as e:
        return make_response(f'Error: {e}', 500)

@strategy_blueprint.route('/get_strategy_hist_trades')
def get_strategy_hist_trades():  # <-- Status: Passing All Tests
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

        return make_response(db_model.get_historical_trades(strategy, lookback), 200)
    except Exception as e:
        return make_response(f'Error: {e}', 500)

@strategy_blueprint.route('/get_strategy_open_trades')
def get_strategy_open_trades():  # <-- Status: Passing All Tests
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

        return make_response(db_model.get_open_trades(strategy), 200)
    except Exception as e:
        return make_response(f'Error: {e}', 500)

@strategy_blueprint.route('/get_strategy_pnl')
def get_strategy_pnl():  # <-- Status: Passing All Tests
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
    # First, get the strategy from the request
    try:
        strategy = request.args.get('strategy')
        if db_model.strategy_exists(strategy) == False:
            return make_response(f'Error: Strategy {strategy} does not exist.', 400)
    except Exception as e:
        return make_response(f'Error: {e}', 500)

    # Next, get the P&L from the DB
    try:
        json_data = db_model.get_strategy_pnl(strategy)
    except Exception as e:
        return make_response(f'Error getting Strategy PNL: {e}', 500)

    # Lastly, convert the JSON to a dataframe and perform the necessary data manipulation.
    try:
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
        return make_response(f'Error converting JSON data to a DataFrame: {e}', 500)
        
    # Error with pd.Dataframe - need to pass a list of lists not a list of dicts
    return make_response(json_data, 200)
