import pandas as pd
from matplotlib import pyplot as plt

df = pd.read_csv('.csv')
delta_crix = list()
delta_crix.append(0)

for index, row in df.iterrows():
    if index == 0:
        print(0)
    else:
        new_delta = (df.at[index, 'CRIX'] - df.at[index - 1, 'CRIX']) / df.at[index - 1, 'CRIX']
        delta_crix.append(new_delta)

plt.plot(delta_crix)
plt.xlabel('days')
plt.ylabel('evolution of CRIX indicator')
plt.title(' CRIX index')
plt.show()

df2 = pd.DataFrame({'deltasent': delta_crix})
df['delta_sent'] = df2

k = 0.05
df1 = pd.read_csv('BTCUSDT-1d.csv')
df1['buy_signal'] = 0

for index_1, row in df.iterrows():
    for index, element in df1.iterrows():

        if str(row['Date'])[0:10] == str(element['timestamp'])[0:10]:
            if row['delta_sent'] >= k:
                df1.at[index, 'buy_signal'] = 1

pnl = list()
pnl.append(1000)

for index, row in df1.iterrows():
    if row['buy_signal'] == 1:
        new_profit = pnl[-1] * (df1.at[index + 1, 'close'] / df1.at[index, 'close'])
        pnl.append(new_profit)

plt.plot(pnl)
plt.xlabel('Entry points')
plt.ylabel('Portfolio value')
plt.title("Crix index")
plt.show()
