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



# 			gas = hourly_df['out.natural_gas.clothes_dryer.energy_consumption']+hourly_df['out.natural_gas.heating.energy_consumption']+hourly_df['out.natural_gas.water_systems.energy_consumption']+hourly_df['out.natural_gas.cooking_range.energy_consumption']
# 			oil = hourly_df['out.fuel_oil.heating.energy_consumption']+hourly_df['out.fuel_oil.water_systems.energy_consumption']
# 			propane = hourly_df['out.propane.clothes_dryer.energy_consumption']+hourly_df['out.propane.heating.energy_consumption']+hourly_df['out.propane.water_systems.energy_consumption'] + hourly_df['out.propane.cooking_range.energy_consumption']

# 			heat = (gas+oil+propane)/Nunits
# 			with open('Heat2LoadFit/coeff_'+tp+str(update)+'.pkl', 'rb') as f:
# 				model = pickle.load(f)
# 			elec = elec + model(heat)*Nunits
# 			total_heat = total_heat+heat*Nunits
# 	# np.savetxt('Data/Load/resloadny/FittedElecLoad/FittedElecLoad_'+ct+'-'+tp+'.txt',elec)
# 			# hourly_df_sub = hourly_df[['out.electricity.total.energy_consumption','out.fuel_oil.total.energy_consumption','out.natural_gas.total.energy_consumption','out.propane.total.energy_consumption']]
# 			# # hourly_df.plot(y='out.natural_gas.total.energy_consumption')
# 			# new_columns = {'out.electricity.total.energy_consumption': 'elec_'+tp, 'out.fuel_oil.total.energy_consumption': 'oil_'+tp, 'out.natural_gas.total.energy_consumption': 'gas_'+tp, 'out.propane.total.energy_consumption': 'propane_'+tp }
# 			# hourly_df_sub = hourly_df_sub.rename(columns = new_columns)
# 			# hourly_df_sub = hourly_df_sub/df['units_represented'].values[0]
# 			# df_county = pd.concat([df_county,hourly_df_sub],axis = 1)

# 		else:
# 			continue
# 	np.savetxt('Data/Load/resloadny/FittedElecLoad/FittedElecLoad_'+ct+'.txt',elec)
# 	np.savetxt('Data/Load/resloadny/HeatLoad/Heatload'+ct+'.txt',total_heat)
# 	total_elec = total_elec + elec 
# total_elec = total_elec/1000
# np.savetxt('Data/Load/resloadny/FittedElecLoad.txt',total_elec)