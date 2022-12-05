# imports
from src import db

class DBModel():
    def __init__(self):
        self.cur = db.get_db().cursor()

    ### Generalized Queries to Retrieve Information From Each Table ###

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
            "documentation_link": "Mean Reversion Strategy",
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

        ### Specific Queries ###

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
            # TODO: FIX THIS SQL QUERY
            self.cur.execute(f"""
                Select *
                from strategy 
                join trade on strategy.strategy_id = trade.strategy_id 
                join trade_leg on trade.trade_id = trade_leg.trade_id 
                join fill on trade_leg.leg_no = fill.leg_no and trade_leg.trade_id = fill.trade_id
                where strategy.strategy_name = '{strategy}' and trade_leg.close_time is null
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

    def get_historical_trades(self, strategy: str, lookback: int):
        if lookback == None:
            self.cur.execute(f'select * from trade where strategy_name = "{strategy}"')
        else:
            self.cur.execute(f'select * from trade where strategy_name = "{strategy}" order by trade_id desc limit {lookback}')
    
    def get_all_trades(self, strategy: str, lookback: int):
        """
        Method that retrieves all trades on a strategy.
        Optional parameter lookback will limit the date to which trades are retrieved.
        """
        if lookback == None:
            self.cur.execute("""
            
            """)
            # TODO: Use the query from get_open_trades() but remove the close_time is null clause
        else:
            self.cur.execute("""
            
            """)
            # TODO: Use the query from get_open_trades() but remove the close_time is null clause and add a limit clause
