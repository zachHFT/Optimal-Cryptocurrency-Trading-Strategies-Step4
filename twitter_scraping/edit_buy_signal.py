import pandas as pd


df_2 = pd.read_csv('BTCUSDT-1h-binance.csv')

df = pd.read_csv('datwitter_btc2_elon.csv')
df_2['buy_signal'] = 0
for index_1, row in df.iterrows():
    for index, element in df_2.iterrows():
        if row['timestamp'][0:14] == element['timestamp'][0:14]:
            df_2.at[index, 'buy_signal'] = 1


df_2.to_csv('BTCUSDT-buy_signal-1h.csv', index=False)


