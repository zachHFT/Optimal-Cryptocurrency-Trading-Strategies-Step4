# IMPORTS
import pandas as pd
import math
import os.path
from binance.client import Client
from datetime import datetime
from dateutil import parser
import api

### API
binance_api_key = ""
binance_api_secret = ""

### CONSTANTS
binsizes = {"1m": 1, "5m": 5, "1h": 60, "1d": 1440}
batch_size = 750
binance_client = Client(api_key=binance_api_key, api_secret=binance_api_secret)
start_date = '9 Feb 2017'  # When inserting start_date as a parameter of the below function I would run into an unexpected error which I haven't identified the cause yet.


### FUNCTIONS
def minutes_of_new_data(symbol, kline_size, data, source):
    if len(data) > 0:
        old = parser.parse(data["timestamp"].iloc[-1])
    elif source == "binance":
        old = datetime.strptime(start_date, '%d %b %Y')
    if source == "binance": new = pd.to_datetime(binance_client.get_klines(symbol=symbol, interval=kline_size)[-1][0],
                                                 unit='ms')
    return old, new


def get_all_binance(symbol, kline_size, save=False):  # check that the starting date is what is expected
    os.chdir(os.getcwd())
    filename = '%s-%s-data-from-%s.csv' % (symbol, kline_size, start_date)
    if os.path.isfile(filename):
        data_df = pd.read_csv(filename, delimiter=',')
    else:
        data_df = pd.DataFrame()
    oldest_point, newest_point = minutes_of_new_data(symbol, kline_size, data_df, source="binance")
    delta_min = (newest_point - oldest_point).total_seconds() / 60
    available_data = math.ceil(delta_min / binsizes[kline_size])
    if oldest_point == datetime.strptime(start_date, '%d %b %Y'):
        print('Downloading all available %s data for %s. Be patient..!' % (kline_size, symbol))
    else:
        print('Downloading %d minutes of new data available for %s, i.e. %d instances of %s data.' % (
            delta_min, symbol, available_data, kline_size))

    klines = binance_client.get_historical_klines(symbol, kline_size, oldest_point.strftime("%d %b %Y %H:%M:%S"),
                                                  newest_point.strftime("%d %b %Y %H:%M:%S"))
    data = pd.DataFrame(klines,
                        columns=['timestamp', 'open', 'high', 'low', 'close', 'volume', 'close_time', 'quote_av',
                                 'trades', 'tb_base_av', 'tb_quote_av', 'ignore'])
    data['timestamp'] = pd.to_datetime(data['timestamp'], unit='ms')
    if len(data_df) > 0:
        temp_df = pd.DataFrame(data)
        data_df = data_df[:len(data_df) - 1]
        data_df = data_df.append(temp_df)
    else:
        data_df = data
    data_df.set_index('timestamp', inplace=True)
    if save: data_df.to_csv(filename)
    print('All caught up..! Check that the starting date is correct')
    return data_df, filename


def main():
    print("Hello World!")


if __name__ == "__main__":
    get_all_binance('DOGEUSDT', '1h', save=True)
