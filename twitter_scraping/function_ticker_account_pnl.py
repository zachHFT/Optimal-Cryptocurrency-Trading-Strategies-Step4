import snscrape.modules.twitter as sntwitter
import pandas as pd
from matplotlib import pyplot as plt


def buy_when_tweet(tickers, user, k, df):
    # Creating list to append tweet data to
    tweets_list2 = []
    # Using TwitterSearchScraper to scrape data and append tweets to list
    for i, tweet in enumerate(
            sntwitter.TwitterSearchScraper(tickers + ' since:2018-11-10 until:2021-11-10 from:' + user).get_items()):
        if i > 1500:
            break
        tweets_list2.append([tweet.date, tweet.id, tweet.content, tweet.user.username])

    tweets_df2 = pd.DataFrame(tweets_list2, columns=['timestamp', 'Tweet Id', 'Text', 'Username'])

    df['buy_signal'] = 0
    df['buy_signal_sentiment'] = 0
    for index_1, row in tweets_df2.iterrows():
        for index, element in df.iterrows():

            if str(row['timestamp'])[0:14] == str(element['timestamp'])[0:14]:
                df.at[index, 'buy_signal'] = 1
                text = row['Text']
                blob = TextBlob(text)
                if blob.sentiment.polarity >= 0:
                    df.at[index, 'buy_signal_sentiment'] = 1

    pnl = list()
    pnl.append(1000)

    for index, row in df.iterrows():
        if row['buy_signal'] == 1:
            new_profit = pnl[-1] * (df.at[index + k, 'close'] / df.at[index, 'close'])
            pnl.append(new_profit)

    plt.plot(pnl)
    plt.xlabel('Entry points')
    plt.ylabel('Portfolio value')
    plt.title(tickers + ' strategy profit and loss from' + user)
    plt.show()
    return

    pnl_1 = list()
    pnl_1.append(1000)

    for index, row in df.iterrows():
        if row['buy_signal_sentiment'] == 1:
            new_profit = pnl_1[-1] * (df.at[index + k, 'close'] / df.at[index, 'close'])
            pnl_1.append(new_profit)

    plt.plot(pnl_1)
    plt.xlabel('Entry points')
    plt.ylabel('Portfolio value')
    plt.title(tickers + ' Strategy profit and loss from sentiment analysis of ' + user+' tweets')
    plt.show()
    return


df1 = pd.read_csv('ADAUSDT-1h-binance.csv')
buy_when_tweet('(ADA OR cardano)', 'Bitboy_Crypto', 5, df1)
