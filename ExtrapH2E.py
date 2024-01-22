import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from sklearn.metrics import r2_score
import pickle

update = 8
tracttable = pd.read_csv('Data/spatial_tract_lookup_table.csv')
tt = tracttable[tracttable['state_abbreviation'] == 'NY']
counties = tt['resstock_county_id'].unique()
countycodes = tt['nhgis_county_gisjoin'].unique()
restype = ['mobile_home','multi-family_with_5plus_units','multi-family_with_2_-_4_units','single-family_attached','single-family_detached']
total_elec = 0

for ct in countycodes:
	ct = 'g'+ct[1:]
	df_county = pd.DataFrame()
	elec = 0
	total_heat = 0
	for tp in restype:
		path = Path('resloadny/'+ct+'-'+tp+'.csv')
		if path.is_file():
			df = pd.read_csv('resloadny/'+ct+'-'+tp+'.csv')
			df['timestamp'] = pd.to_datetime(df['timestamp'])
			df.set_index('timestamp', inplace=True)
			Nunits = df['units_represented'].values[1]
			hourly_df = df.resample('H').sum()
			gas = hourly_df['out.natural_gas.clothes_dryer.energy_consumption']+hourly_df['out.natural_gas.heating.energy_consumption']+hourly_df['out.natural_gas.water_systems.energy_consumption']+hourly_df['out.natural_gas.cooking_range.energy_consumption']
			oil = hourly_df['out.fuel_oil.heating.energy_consumption']+hourly_df['out.fuel_oil.water_systems.energy_consumption']
			propane = hourly_df['out.propane.clothes_dryer.energy_consumption']+hourly_df['out.propane.heating.energy_consumption']+hourly_df['out.propane.water_systems.energy_consumption'] + hourly_df['out.propane.cooking_range.energy_consumption']

			heat = (gas+oil+propane)/Nunits
			with open('Heat2LoadFit/coeff_'+tp+str(update)+'.pkl', 'rb') as f:
				model = pickle.load(f)
			elec = elec + model(heat)*Nunits
			total_heat = total_heat+heat*Nunits
	# np.savetxt('resloadny/FittedElecLoad/FittedElecLoad_'+ct+'-'+tp+'.txt',elec)
			# hourly_df_sub = hourly_df[['out.electricity.total.energy_consumption','out.fuel_oil.total.energy_consumption','out.natural_gas.total.energy_consumption','out.propane.total.energy_consumption']]
			# # hourly_df.plot(y='out.natural_gas.total.energy_consumption')
			# new_columns = {'out.electricity.total.energy_consumption': 'elec_'+tp, 'out.fuel_oil.total.energy_consumption': 'oil_'+tp, 'out.natural_gas.total.energy_consumption': 'gas_'+tp, 'out.propane.total.energy_consumption': 'propane_'+tp }
			# hourly_df_sub = hourly_df_sub.rename(columns = new_columns)
			# hourly_df_sub = hourly_df_sub/df['units_represented'].values[0]
			# df_county = pd.concat([df_county,hourly_df_sub],axis = 1)

		else:
			continue
	np.savetxt('resloadny/FittedElecLoad/FittedElecLoad_'+ct+'.txt',elec)
	np.savetxt('resloadny/HeatLoad/Heatload'+ct+'.txt',total_heat)
	total_elec = total_elec + elec 
total_elec = total_elec/1000
np.savetxt('resloadny/FittedElecLoad.txt',total_elec)