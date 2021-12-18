import pandas as pd
import matplotlib.pyplot as plt
k = 24

df = pd.read_csv('BTCUSDT0-buy_signal-sentiment-1h.csv')

pnl = list()
pnl.append(1000)

for index, row in df.iterrows():
    if row['buy_signal'] == 1:
        new_profit = pnl[-1] * (df.at[index + k, 'close'] / df.at[index, 'close'])
        pnl.append(new_profit)

plt.plot(pnl)
plt.xlabel('Entry points')
plt.ylabel('Portfolio value')
plt.title('DOGE sentiment strategy profit and loss')
plt.show()

