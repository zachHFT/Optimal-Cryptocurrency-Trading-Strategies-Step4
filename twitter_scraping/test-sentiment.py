from textblob import TextBlob
import pandas as pd

text = 'hello. I m in love'

print()

df_2 = pd.read_csv('DOGEUSDT-1h.csv')

df = pd.read_csv('datwitter_btc2_elon.csv')
df_2['buy_signal'] = 0
for index_1, row in df.iterrows():
    for index, element in df_2.iterrows():
        if row['timestamp'][0:14] == element['timestamp'][0:14]:
            text = row['Text']
            blob = TextBlob(text)
            if blob.sentiment.polarity >= 0:
                df_2.at[index, 'buy_signal'] = 1

df_2.to_csv('DOGEUSDT0-buy_signal-sentiment-1h.csv', index=False)
