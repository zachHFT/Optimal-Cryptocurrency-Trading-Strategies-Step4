import pandas as pd
from matplotlib import pyplot as plt

df = pd.read_csv('final_dataset.csv')
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

df1 = pd.DataFrame({'deltasent':delta_crix})
df['delta_sent'] = df1

df.to_csv('Crix_final.csv', sep='\t')
