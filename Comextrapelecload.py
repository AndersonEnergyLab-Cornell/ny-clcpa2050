import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from matplotlib import pyplot as plt
from sklearn.ensemble import RandomForestRegressor
from sklearn.neural_network import MLPRegressor
from sklearn.preprocessing import StandardScaler
from sklearn import metrics
from sklearn.model_selection import RandomizedSearchCV
import math
import pickle
import os
import sys



tracttable = pd.read_csv('Data/spatial_tract_lookup_table.csv')
tt = tracttable[tracttable['state_abbreviation'] == 'NY']
counties = tt['nhgis_county_gisjoin'].unique()
countymap = pd.read_csv('countywithpoint.csv')
ctname2bus = pd.read_csv('county2bus.csv')
deltatemp = pd.read_csv('Load/temperature.changes.csv')
# for scenario in [47,52,107,90,158,134,87,82,20,99,27,23,54,157,55,108,111,132,155,94]:
for scenario in range(1,160):
#1980-2019
#2036-2085
	dtemp = deltatemp[deltatemp['scenario']==scenario]['temperature_change_deg_C'][scenario-1]
	# dtemp = 0
	for year in range(1998,2020):
		total = 0
		ct_dict = {}
		for ct in counties:
		# ct = 'G3601090'
			# print(ct)
			ct = 'g'+ct[1:]
			fips = float(ct[1:3]+ct[4:7])
			coord = countymap[countymap['FIPS_CODE']==fips]['nearest_point'].values[0]
			coord_arr = np.fromstring(coord[1:-1], sep=' ')
			countyname = countymap[countymap['FIPS_CODE']==fips]['NAME'].values[0]
			if len(str(round(coord_arr[1],2)))==5:
				weather = pd.read_csv('Data/NSRDB/weather_'+str(coord_arr[0])+'_'+str(round(coord_arr[1],2))+'0_'+str(year)+'.csv')
			else:

				weather = pd.read_csv('Data/NSRDB/weather_'+str(coord_arr[0])+'_'+str(round(coord_arr[1],2))+'_'+str(year)+'.csv')
			x = weather.to_numpy()

			nrow,ncol = np.shape(x)

			drybulb = x[:,10].reshape(int(nrow/24),24)+dtemp
			humid = x[:,9].reshape(int(nrow/24),24)
			windspeed = x[:,8].reshape(int(nrow/24),24)
			winddirect = x[:,12].reshape(int(nrow/24),24)
			hrad = x[:,11].reshape(int(nrow/24),24)
			nrad = x[:,7].reshape(int(nrow/24),24)
			drad = x[:,6].reshape(int(nrow/24),24)
			hod = x[:,4].reshape(int(nrow/24),24)
			t = range(0,int(nrow/24))
			tme = [math.sin(2*math.pi*x/int(nrow/24)) for x in t]
			tcyclic = np.reshape(tme,(int(nrow/24),1))
			xx = np.hstack((drybulb,humid,windspeed,winddirect,hrad,nrad,drad,hod,tcyclic))
			sc = StandardScaler()
			# x_input = sc.fit_transform(xx)
			x_input = xx
			filename = 'comloadny/annWeather2Elec/annw2e_'+ct+'_model.sav'
			model = pickle.load(open(filename, 'rb'))
			Y_output = model.predict(x_input)
			# np.savetxt('Load/ResLoad/'+str(year)+'/elecload_'+ ct+'.txt',Y_output)
			Y = Y_output.reshape(nrow,)
			if countyname == 'Erie':
				ct_dict['55'] = 0.5*Y
				ct_dict['57'] = 0.125*Y
				ct_dict['59'] = 0.375*Y
			elif countyname == 'Westchester':
				ct_dict['74'] = 0.5*Y
				ct_dict['78'] = 0.5*Y
			else:
				bus = ctname2bus[ctname2bus['NAME'] == countyname]['busIdx'].values[0]
				if str(bus) in list(ct_dict.keys()):
					ct_dict[str(bus)] =ct_dict[str(bus)]+ Y.T
				else:
					ct_dict[str(bus)] = Y.T

			
			total = total + Y
		# print(ct_dict)
		ct_list = []
		for key,value in ct_dict.items():
			ct_list.append(np.insert(value/1000,0,float(key)))

		# ct_list = [[float(k)] + v for k, v in ct_dict.items()]
		# ct_array = np.array(ct_list)
		# format the numpy array with floating point format specifier
		ct_array = np.array(ct_list)
		# print(formatted)
		ct_array = ct_array
		directory = 'Load/ComLoad/Scenario'+str(scenario)

		if not os.path.exists(directory):
			os.makedirs(directory)
			
		# ct_array = ct_array.reshape((46,8761))
		np.savetxt('Load/ComLoad/Scenario'+str(scenario)+'/ComLoad_Bus_'+str(year)+'.csv',ct_array,delimiter=',')
	# np.savetxt('Load/ResLoad/'+str(year)+'/elecload.txt',total)
	# plt.plot(total)
	# plt.show()



