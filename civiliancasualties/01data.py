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
from plotfunc import *

#%%
incident = pd.read_stata('data/ESOC-I_Replication_V3/stata/incident/esoc-iraq-v3_sigact_district-month.dta')
shape = gpd.read_file('data/ESOC-I_Replication_V3/gis/Iraq_district_boundaries_UTM.shp')

#%%
sorted(incident.columns)


#%%
shape.head()


#%%
summed = incident.groupby(["district"]).sum().reset_index()
merged = shape.set_index('ADM3NAME').join(summed.set_index('district'))

#%%
renderPlot(merged, "ied_total", "Total IED related incidents in Iraq")

#%%
merged

#%%
