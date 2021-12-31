import pandas as pd
from matplotlib import pyplot as plt

vol_stkt = pd.read_csv('stocktwits_volume.csv')
vol_redcmt = pd.read_csv('reddit_comments_volume.csv')
vol_redsub = pd.read_csv('reddit_submissions_volume.csv')
df = pd.read_csv('final_dataset.csv')
vol_google = df['Search Volume']
sent = vol_google

for index in range(len(sent)):
    sent[index] = 0.499 * vol_google[index] + 0.419 * vol_stkt.at[index, 'volume'] + 0.534 * vol_redsub.at[
        index, 'volume'] + 0.539 * vol_redcmt.at[index, 'volume']

df['sent'] = sent
delta_sent = list()
delta_sent.append(0)

for index, row in df.iterrows():
    if index == 0:
        print(0)
    else:
        new_delta = (df.at[index, 'sent'] - df.at[index - 1, 'sent'])
        delta_sent.append(new_delta)

df2 = pd.DataFrame({'delta_sent': delta_sent})
df['delta_sent'] = df2

df1 = pd.read_csv('BTCUSDT-1d.csv')
df1['buy_signal'] = 0

for index_1, row in df.iterrows():
    for index, element in df1.iterrows():

        if str(row['Date'])[0:10] == str(element['timestamp'])[0:10]:
            if row['delta_sent'] >= 0:
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
plt.title("sent index")
plt.show()
