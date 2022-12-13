# imports
from src import db
from datetime import datetime
from dateutil.relativedelta import relativedelta
import pandas as pd

class DBModel():
    def __init__(self):
        self.cur = db.cursor()

    ### HOME PAGE ###

    def get_strategy_info(self, strategy: str):
        """
        Method to get all current information for a particular strategy or all strategies (in the event that strategy is '*').
        Output will come in the format of a JSON object with all attributes of the strategy table.

        ----- Example -----

        The following would represent the resulting information for a request of info on the MeanReversion strategy:

        get_strategy_info('MeanReversion'):
        {
            "strategy_name": "MeanReversion",
            "strategy_id": 1,
            "documentation_link": "github.com/NTSLightning/mrs",
            "launch_date": "2021-01-01 00:00:00",
            "termination_date": None
        }
        """

        try:
            if strategy == '*':
                self.cur.execute(f'select * from strategy')
            else:
                self.cur.execute(f'select * from strategy where strategy_name = "{strategy}"')
        except Exception as e:
            return f'Error retrieving strategy information: {e}'

        col_headers = [x[0] for x in self.cur.description]
        json_data = []
        the_data = self.cur.fetchall()
        for row in the_data:
            json_data.append(dict(zip(col_headers, row)))
        return json_data
    
    def get_daily_pnl(self):
        """
        Method to get all daily P&L across the entire portfolio. Data requires further cleaning in the strategy api method.
        """
        try:
            self.cur.execute("""
                Select trade.open_time as Date, sum(fill.qty * fill.avg) * -1 as pnl
                from trade
                join trade_leg on trade.trade_id = trade_leg.trade_id
                join fill on trade_leg.leg_no = fill.leg_no and trade_leg.trade_id = fill.trade_id
                group by trade.open_time
                order by trade.open_time;
                """)
        except Exception as e:
            return f'Error retrieving strategy information: {e}'

        col_headers = [x[0] for x in self.cur.description]
        json_data = []
        the_data = self.cur.fetchall()
        for row in the_data:
            json_data.append(dict(zip(col_headers, row)))
        return json_data

    def get_active_strategies(self):
        """
        Get a list of all active strategies. An active strategy is defined as one that is currently running on an EC2.
        Returns all attributes of the strategy table.
        """
        
        try:
            self.cur.execute(f'select * from strategy where termination_date is null')
        except Exception as e:
            return f'Error retrieving strategy information: {e}'

        col_headers = [x[0] for x in self.cur.description]
        json_data = []
        the_data = self.cur.fetchall()
        for row in the_data:
            json_data.append(dict(zip(col_headers, row)))
        return json_data

    def get_strategy_statistics(self, strategy):
        """
        Method to get a strategy's performance stats. Stats will be exclusive of all open trades.
        Output will come as a JSON in the format:
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
        strategy_pnl_json = self.get_strategy_pnl(strategy)
        try:
            df = pd.DataFrame(strategy_pnl_json)
        except Exception as e:
            return f'Error converting strategy information to JSON: {e}'
        
        cum_pnl = df['PNL'].sum()
        ytd_pnl = df[df['Date'] >= datetime.now().replace(month=1, day=1, hour=0, minute=0, second=0, microsecond=0)].sum()['PNL']
        avg_annual_return = (cum_pnl / df['PNL'].count()) * 252
        avg_daily_return = (cum_pnl / df['PNL'].count())
        avg_trades_per_day = df['PNL'].count() / (df['Date'].max() - df['Date'].min()).days
        sharpe = cum_pnl / df['PNL'].std()
        
        r_json = {
            'cumulative_pnl': round(cum_pnl, 2),
            'ytd_pnl': round(ytd_pnl, 2),
            'avg_annual_return': round(avg_annual_return, 2),
            'avg_daily_return': round(avg_daily_return, 2),
            'avg_daily_trades': round(avg_trades_per_day, 2),
            'sharpe': round(sharpe, 2)
        }

        return r_json


    ### STRAGEGY PAGE ###

    def get_strategy_pnl(self, strategy):
        """
        Method to get all daily P&L across the life of a strategy. Data requires further cleaning in the strategy api method.
        """
        try:
            self.cur.execute(f"""
                Select trade.open_time as Date, sum(fill.qty * fill.avg) * -1 as PNL
                from trade
                join trade_leg on trade.trade_id = trade_leg.trade_id
                join fill on trade_leg.leg_no = fill.leg_no and trade_leg.trade_id = fill.trade_id
                join strategy on trade.strategy_id = strategy.strategy_id
                where strategy.strategy_name = "{strategy}"
                group by trade.open_time
                order by trade.open_time;
                """)
        except Exception as e:
            return f'Error retrieving strategy information: {e}'

        col_headers = [x[0] for x in self.cur.description]
        json_data = []
        the_data = self.cur.fetchall()
        for row in the_data:
            json_data.append(dict(zip(col_headers, row)))
        return json_data

    def get_open_trades(self, strategy: str):
        """
        Method to get all open trades on a particular strategy.
        Output will come in the format of a JSON object with attributes as described below:
        
        ----- Example -----

        The following represents a trade made under the MeanReversionLunchBreak strategy that:
        - Has one open trade (trade_id = 000000001)
            - Which has one trade_leg (leg_no = 1)
                - Which has one fill (the opening fill)

        get_open_trades("MeanReversionLunchBreak"):
        {
            "strategy_name": "MeanReversionLunchBreak",
            "trade": [
                {
                    "trade_id": 000000001,
                    "trade_leg": [
                        {
                            "leg_no": 1,
                            "fill": [
                                {
                                    "fill_id": 000000001,
                                    "contract": "GME",
                                    "qty": 420,
                                    "avg": 69.69,
                                    "placement_time": "2021-01-01 00:00:00",
                                    "fill_time": "2021-01-01 00:00:01"
                                }
                            ],
                            "contract": "GME",
                            "open_time": "2021-02-01 00:00:00"
                        }
                    ],
                    "open_time": "2021-02-01 00:00:00"
                }
            ]
        }
        """

        try:
            self.cur.execute(f"""
                Select trade.trade_id as trade_id, trade.open_time as open_time, trade_leg.contract as contract,
                max(trade_leg.leg_no) as no_legs, count(fill.fill_id) as fills, sum(fill.qty * fill.avg) as capital_out
                from strategy 
                join trade on strategy.strategy_id = trade.strategy_id 
                join trade_leg on trade.trade_id = trade_leg.trade_id 
                join fill on trade_leg.leg_no = fill.leg_no and trade_leg.trade_id = fill.trade_id
                where strategy.strategy_name = '{strategy}' and trade.close_time is NULL
                group by trade_id
                order by trade.open_time;
                """)
        except Exception as e:
            return f'Error retrieving open trades: {e}'

        col_headers = [x[0] for x in self.cur.description]
        json_data = []
        the_data = self.cur.fetchall()
        for row in the_data:
            json_data.append(dict(zip(col_headers, row)))
        return json_data

    def get_historical_trades(self, strategy: str, lookback):
        if lookback == 0:
            self.cur.execute(f"""
                Select trade.trade_id as trade_id, trade.open_time as open_time, trade.close_time as close_time, trade_leg.contract as contract,
                max(trade_leg.leg_no) as no_legs, count(fill.fill_id) as fills, sum(fill.qty * fill.avg) * -1 as pnl 
                from strategy 
                join trade on strategy.strategy_id = trade.strategy_id 
                join trade_leg on trade.trade_id = trade_leg.trade_id 
                join fill on trade_leg.leg_no = fill.leg_no and trade_leg.trade_id = fill.trade_id
                where strategy.strategy_name = '{strategy}'
                group by trade_id
                order by trade.open_time;
                """)
        else:
            # Convert the lookback into a datetime object that is lookback months from today
            lookback = datetime.now() - relativedelta(months=lookback)
            lookback = lookback.strftime("%Y-%m-%d %H:%M:%S")
            self.cur.execute(f"""
                Select trade.trade_id as trade_id, trade.open_time as open_time, trade.close_time as close_time, trade_leg.contract as contract,
                max(trade_leg.leg_no) as no_legs, count(fill.fill_id) as fills, sum(fill.qty * fill.avg) * -1 as pnl 
                from strategy 
                join trade on strategy.strategy_id = trade.strategy_id 
                join trade_leg on trade.trade_id = trade_leg.trade_id 
                join fill on trade_leg.leg_no = fill.leg_no and trade_leg.trade_id = fill.trade_id
                where strategy.strategy_name = '{strategy}' and trade.open_time > '{lookback}' 
                group by trade_id
                order by trade.open_time;
                """)
                
        col_headers = [x[0] for x in self.cur.description]
        json_data = []
        the_data = self.cur.fetchall()
        for row in the_data:
            json_data.append(dict(zip(col_headers, row)))
        return json_data

    ### DATA EXPLORER PAGE ###

    
    def get_trade_info(self, trade_id: int):
        # TODO: FIX THIS SQL QUERY
        """
        Method to get all current information for a particular trade identified by the trade_id parameter.
        Output will come in the format of a JSON object with all attributes of the trade table.

        ----- Example -----

        The following would represent the return of a trade with one leg:
        - a leg of a trade on GME with two fills:
            - an opening fill for 420 shares of GME at $69.69
            - a closing fill for 420 shares of GME at $70.00

        get_trade_info(000000001):
        {
            "trade_id": 000000001,
            "strategy_name": "GME",
            "trade_leg": [
                {
                    "trade_id": 000000001,
                    "leg_no": 1,
                    "fill": [
                        {
                            "fill_id": 000000001,
                            "contract": "GME",
                            "qty": 420,
                            "avg": 69.69,
                            "placement_time": "2021-01-01 00:00:00",
                            "fill_time": "2021-01-01 00:00:01"
                        },
                        {
                            "fill_id": 000000002,
                            "contract": "GME",
                            "qty": -420,
                            "avg": 70.00,
                            "placement_time": "2021-01-01 00:01:00",
                            "fill_time": "2021-01-01 00:01:02"
                        }
                    ],
                    "contract": "GME",
                    "open_time": "2021-02-01 00:00:00",
                    "close_time": "2021-02-01 00:01:00"
                }
            ],
            "open_time": "2021-02-01 00:00:00",
            "close_time": "2021-02-01 00:01:00"
        }
        """

        try:
            self.cur.execute(f'select * from trade where trade_id = {trade_id}')
        except Exception as e:
            return f'Error retrieving trade information: {e}'

        col_headers = [x[0] for x in self.cur.description]
        json_data = []
        the_data = self.cur.fetchall()
        for row in the_data:
            json_data.append(dict(zip(col_headers, row)))
        return json_data
    
    def get_trade_leg_info(self, trade_id: int, leg_no: int):
        """
        Method to get all current information for a particular trade leg identified by the trade_id and leg_no parameters.
        Output will come in the format of a JSON object with all attributes of the trade_leg table.

        ----- Example -----

        The following would represent a leg of a trade on GME with two fills: 
        - an opening fill for 420 shares of GME at $69.69
        - a closing fill for 420 shares of GME at $70.00

        get_trade_leg_info(000000001, 1):
        {
            "trade_id": 000000001,
            "leg_no": 1,
            "fill": [
                {
                    "fill_id": 000000001,
                    "contract": "GME",
                    "qty": 420,
                    "avg": 69.69,
                    "placement_time": "2021-01-01 00:00:00",
                    "fill_time": "2021-01-01 00:00:01"
                },
                {
                    "fill_id": 000000002,
                    "contract": "GME",
                    "qty": -420,
                    "avg": 70.00,
                    "placement_time": "2021-01-01 00:01:00",
                    "fill_time": "2021-01-01 00:01:02"
                }
            ],
            "contract": "GME",
            "open_time": "2021-02-01 00:00:00",
            "close_time": "2021-02-01 00:01:00"
        }
        """

        try:
            self.cur.execute(f"""
                Select * from trade_leg join fill on trade_leg.leg_no = fill.leg_no and trade_leg.trade_id = fill.trade_id
                where trade_leg.trade_id = {trade_id} and trade_leg.leg_no = {leg_no}
                order by fill.placement_time;
                """)
        except Exception as e:
            return f'Error retrieving trade leg information: {e}'

        col_headers = [x[0] for x in self.cur.description]
        json_data = []
        the_data = self.cur.fetchall()
        for row in the_data:
            json_data.append(dict(zip(col_headers, row)))
        return json_data

    def get_fill_info(self, fill_id: int):
        """
        Method to get all current information for a particular fill identified by the fill_id parameter.
        Output will come in the format of a JSON object with all attributes of the fill table.
        ----- Example -----
        get_fill_info(000000001):
        {
            "fill_id": 000000001,
            "contract": "GME",
            "qty": 420,
            "avg": 69.69,
            "placement_time": "2021-01-01 00:00:00",
            "fill_time": "2021-01-01 00:00:01"
        }
        """

        try:
            self.cur.execute(f'select * from fill where fill_id = {fill_id}')
        except Exception as e:
            return f'Error retrieving fill information: {e}'
        
        col_headers = [x[0] for x in self.cur.description]
        json_data = []
        the_data = self.cur.fetchall()
        for row in the_data:
            json_data.append(dict(zip(col_headers, row)))
        return json_data

    