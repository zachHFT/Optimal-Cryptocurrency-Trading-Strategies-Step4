# -*- coding: utf-8 -*-

# -- Sheet --

#%pip install python-binance #This package is not present in the standard library databases, need to pip install it

# IMPORTS
import pandas as pd
import math
import os.path
from datetime import datetime, timedelta
from datetime import date
from dateutil import parser
import pickle
import asyncio
import dateutil.parser
import imp
import json
import numpy as np
import matplotlib.pyplot as plt

from binance.client import Client

#import api #You need to create your own api.py file which contains the api keys
import get_uptodate_binance_data

'''function that preprocess our dataframe according to our needs'''
def preparing_df(filename, timeframe):
    OHLC_directory = '/data/workspace_files/Data/Binance_OHLC/'
    complete_file_path = OHLC_directory + filename
    df = pd.read_csv(complete_file_path)
    df['closeprice_log_return']=np.log(df.close) - np.log(df.close.shift(1))
    df['datetime'] = pd.to_datetime(df['timestamp'], errors='coerce')
    df['time_difference'] = df.datetime.diff()

    df.drop(['high', 'volume', 'close_time', 'quote_av', 'trades', 'tb_base_av', 'tb_quote_av', 'ignore'], axis = 1, inplace = True)
    df = df.iloc[1: , :] #Remove first row which contains NA due to log-return
    
    return df

''' function that plots the pnl across time'''
def draw_pnl(df, pnl):
    
    baseline = df['close']/df['close'][1] * 1000

    plt.figure(figsize=(8, 5))
    plt.plot(baseline,label = "buy-and-hold", linestyle=":")
    plt.plot(pnl,label = "our strategy", linestyle="--")
    #plt.plot(pnl2,label = "Kyber  Same  Day", linestyle="-")
    plt.xlabel('Time',fontsize=20)

    plt.ylabel('PnL',fontsize=20)
    plt.title('The evolution of PnL',fontsize=15)
    plt.legend( prop={'size': 15})
    plt.show()

nb_iterations = 10000
filename_watch = 'BTCUSDT-1d-binance.csv'
filename_buy = 'ETHUSDT-1d-binance.csv'
timeframe = '1d'
df_watch = preparing_df(filename_watch, timeframe)
df_buy = preparing_df(filename_watch, timeframe)

pnl = compute_pnl_strategy(df_watch[:nb_iterations], df_buy[:nb_iterations])
draw_pnl(df_buy[:nb_iterations], pnl)



