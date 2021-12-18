
from textblob import TextBlob


text = 'you cann buy tesla with bitcoin'
blob = TextBlob(text)
print(blob.sentiment.polarity)