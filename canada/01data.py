#%%
%matplotlib inline
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import geopandas as gpd
import descartes
import imageio
import pathlib
import seaborn as sns
from plotfunc import *

pd.options.display.max_columns = 20  # None -> No Restrictions
pd.options.display.max_rows = 50
pd.options.display.max_colwidth = 100
pd.options.display.precision = 3
pd.set_option('display.max_columns', None)

#%% [markdown]
Pulling in the [Canadian Incident Database data](https://www.tsas.ca/canadian-incident-database/).
Note: Coding that is -88 or -99 is unknown or not applicable respectively re the [contributors manual](
http://extremism.ca/Content/CIDB_Data_Contributor_Manual_EN.pdf)

#%%
df = pd.read_csv('data/canadian_incident_database.csv', sep='\t',  index_col=False)
sorted(df.columns)
#%%
# Checking to make sure there's no null
df[['Event_Year', 'Event_Month', 'Event_Day']].isnull().values.any()

#%%
df.fillna(0)
# df['Datetime_Start'] = pd.to_datetime(df[['Event_Year', 'Event_Month', 'Event_Day']])


#%%
df[["Fatalities","Event_Year"]].groupby("Event_Year").sum().abs()

#%%
sns.set_style("darkgrid")
plt.plot(df[["Fatalities","Event_Year"]].groupby("Event_Year").sum().abs())
plt.show()

#%%
df[[df["Event_Year"] == 1985],["Fatalities"]]

#%%
df.groupby("Hoax").describe()

#%%
sns.set_style("darkgrid")
plt.plot(df[["Hoax","Event_Year"]].groupby("Event_Year").count())
plt.show()

#%%
