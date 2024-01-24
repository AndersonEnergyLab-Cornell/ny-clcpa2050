import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from sklearn.metrics import r2_score
import pickle

update = 3
tracttable = pd.read_csv('Data/spatial_tract_lookup_table.csv')
tt = tracttable[tracttable['state_abbreviation'] == 'NY']
counties = tt['resstock_county_id'].unique()
countycodes = tt['nhgis_county_gisjoin'].unique()
comtype = ['fullservicerestaurant','largehotel','largeoffice','mediumoffice','outpatient','primaryschool','quickservicerestaurant','retailstandalone',
'retailstripmall','secondaryschool','smallhotel','smalloffice','warehouse']
total_elec = 0
for ct in countycodes:
	ct = 'g'+ct[1:]
	elec = 0
	for tp in comtype:
		print(tp)
		df = pd.read_csv('Data/Load/comloadny/update'+str(update)+'/up0'+str(update)+'-ny-'+tp+'.csv')
		df['timestamp'] = pd.to_datetime(df['timestamp'])
		df.set_index('timestamp', inplace=True)
		totalNunits = df['floor_area_represented'].values[1]
		hourly_df = df.resample('H').sum()
		path = Path('Data/Load/comloadny/comloadraw/'+ct+'-'+tp+'.csv')
		if path.is_file():
			df_county = pd.read_csv('Data/Load/comloadny/comloadraw/'+ct+'-'+tp+'.csv')
			Nunits = df_county['floor_area_represented'].values[1]
			elec = elec+ hourly_df['out.electricity.total.energy_consumption.kwh.savings'].values/totalNunits*Nunits
		else:
			continue
	np.savetxt('Data/Load/comloadny/FittedElecLoad/FittedElecLoad_'+ct+'.txt',elec)
