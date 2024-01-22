import numpy as np
import pandas as pd
from matplotlib import pyplot as plt


tracttable = pd.read_csv('Data/spatial_tract_lookup_table.csv')
tt = tracttable[tracttable['state_abbreviation'] == 'NY']
counties = tt['nhgis_county_gisjoin'].unique()
countymap = pd.read_csv('countywithpoint.csv')
ctname2bus = pd.read_csv('county2bus.csv')
qmday = pd.read_csv('Data/qm_to_numdays.csv')
qmday['hours'] = qmday['Days']*24
Mshy = pd.read_csv('Data/hydrodata/nypaMosesSaundersEnergy.climate.change.csv')
Nahy = pd.read_csv('Data/hydrodata/nypaNiagaraEnergy.climate.change.csv')
# zonelist = ['A','B','C','D','E','F','GHI','JK']
zonelist = ['B','E','GHI','JK']
coord = {'A':[43.0,-78.75],
		'B':[43.0,-78.75],
		'C':[42.5,-76.875],
		'D':[44.5,-74.375],
		'E': [43.0,-75.625],
		'F':[43.5,-73.75],
		'GHI':[42.0,-74.375],
		'JK':[40.5,-73.75]}

# coord = np.array([[43.0,-78.75],[43.0,-78.75],[42.5,-76.875],[44.5,-74.375],[43.0,-75.625],[43.5,-73.75],[42.0,-74.375],[40.5,-73.75]])
# A = [54,55, 56, 57, 58, 59, 60, 61] # [43.0,-78.75]
# B = [62, 52, 53]#[43.0,-78.75]
# C = [50, 51, 63, 64, 65, 66, 67, 68, 70, 71, 72]#[42.5,-76.875]
# D = [48, 49] #[44.5,-74.375]
# E = [69, 38, 43, 44, 45, 46, 47]#[43.0,-75.625]
# F = [40, 41, 42, 37]#[43.5,-73.75]
# G = [39, 73, 75, 76, 77]#[42.0,-74.375]
# H = 74
# I = 78
# J = [82, 81]#[40.5,-73.75]
# K = [79, 80]
# coordlist = np.empty((1,2))
# for bus in B:
# 	counties = ctname2bus[ctname2bus['busIdx'] == bus]['NAME']
# 	for cname in counties:
# 		print(bus,cname)
# 		coord = countymap[countymap['NAME'] == cname]['nearest_point'].values[0]
# 		coord_arr = np.fromstring(coord[1:-1], sep=' ')
# 		print(coord_arr)
# 		coordlist = np.vstack([coordlist,coord_arr])

# print(coordlist)
# plt.scatter(coordlist[1:,0],coordlist[1:,1])
# plt.show()
alldfs = []
for year in range(1998,2020):
	print(year)
	DU_factors = np.loadtxt('SolarS0_300_v2/objs_'+str(year)+'.csv', delimiter= ',')
	DU_f = np.loadtxt('DU_factors_300.csv',delimiter= ',')
	DU_f_sorted = DU_f[DU_f[:, 10].argsort()]
	# print(DU_f_sorted)
	for scenario in range(0,300):
		print(scenario)
		zonaldfs = []
		for zone in zonelist:
			# print(zone,str(zone))
			coord_arr = coord[zone]
			if len(str(round(coord_arr[1],2)))==5:
				weather = pd.read_csv('Data/NSRDB/weather_'+str(coord_arr[0])+'_'+str(round(coord_arr[1],2))+'0_'+str(year)+'.csv')
			else:
				weather = pd.read_csv('Data/NSRDB/weather_'+str(coord_arr[0])+'_'+str(round(coord_arr[1],2))+'_'+str(year)+'.csv')

			chunk_size = 168
			###### chunck size should match the one from hydro. 

			# create a new column with the group numbers for each row
			if len(weather)>8760:
				weather = weather.head(8760)
			weather['group'] = np.repeat(qmday['QM'].values, qmday['hours'].values)
			shydro = int(DU_f_sorted[scenario,10])
			hydro1 = Mshy[Mshy['Year']==year]['nypaMosesSaundersEnergy.'+str(shydro)]
			hydro2 = Nahy[Nahy['Year']==year]['nypaNiagaraEnergy.'+str(shydro)]

			# calculate the mean, max and min for each group
			result = weather.groupby('group').agg(['mean', 'max', 'min'])
			feature = {	
			# 'Windv_min_'+zone:result['Wind Speed']['min'].min(),
						# 'Windv_max_'+zone:result['Wind Speed']['max'].max(),
						'Windv_mean_'+zone:result['Wind Speed']['mean'].mean(),
						# 'Temp_min_'+zone:result['Temperature']['min'].min(),
						# 'Temp_max_'+zone:result['Temperature']['max'].max(),
						'Temp_mean_'+zone:result['Temperature']['mean'].mean(),
						# 'DHI_min_'+zone:result['DHI']['min'].values,
						# 'DHI_max_'+zone:result['DHI']['max'].values,
						# 'DHI_mean_'+zone:result['DHI']['mean'].values,
						# # 'DNI_min_'+zone:result['DNI']['min'].values,
						# 'DNI_max_'+zone:result['DNI']['max'].values,
						# 'DNI_mean_'+zone:result['DNI']['mean'].values,
						# 'GHI_min_'+zone:result['GHI']['min'].values,
						# 'GHI_max_'+zone:result['GHI']['max'].max(),
						'GHI_mean_'+zone:result['GHI']['mean'].min()}
						# 'Humid_min_'+zone:result['Relative Humidity']['min'].values,
						# 'Humid_max_'+zone:result['Relative Humidity']['max'].values,
						# 'Humid_mean_'+zone:result['Relative Humidity']['mean'].values}
						# 'Winda_min_'+zone:result['Wind Direction']['min'].values,
						# 'Winda_max_'+zone:result['Wind Direction']['max'].values,
						# 'Winda_mean_'+zone:result['Wind Direction']['mean'].values}
			df_feature = pd.DataFrame(feature, index=[0])
			zonaldfs.append(df_feature)
		# print the result
		zonalfeatures = pd.concat(zonaldfs, axis=1)
		# zonalfeatures['QM'] = qmday['QM']
		zonalfeatures['Hydro_ms'] = hydro1.min()
		zonalfeatures['Hydro_na'] = hydro2.min()
		zonalfeatures['temp_increase'] = DU_factors[scenario,0]
		zonalfeatures['bd_rate_AE'] = DU_factors[scenario,1]
		zonalfeatures['bd_rate_FI'] = DU_factors[scenario,2]
		zonalfeatures['bd_rate_JK'] = DU_factors[scenario,3]
		zonalfeatures['ev_rate_AE'] = DU_factors[scenario,4]
		zonalfeatures['ev_rate_FI'] = DU_factors[scenario,5]
		zonalfeatures['ev_rate_JK'] = DU_factors[scenario,6]
		zonalfeatures['windcap'] = DU_factors[scenario,7]
		zonalfeatures['solarcap'] = DU_factors[scenario,8]
		zonalfeatures['battcap'] = DU_factors[scenario,9]

		# zonalfeatures['season'] = zonalfeatures['QM'].apply(lambda x: 'summer' if x > 16 and x<=36 else 'winter')
		alldfs.append(zonalfeatures)
allfeature = pd.concat(alldfs)
allfeature.to_csv('SolarS0_300_v2/DUfeature_lg.csv')
	# plt.plot(weather['Temperature'])
	# plt.plot(weather['Wind Speed'])
	# plt.plot(weather['Relative Humidity'])
	# plt.plot(weather['GHI'])
# 	plt.plot(weather['DNI'])
# plt.show()

# # obj = np.loadtxt('SolarS0_300_v2/objs_'+str(year)+'.csv', delimiter= ',')

# weather = 