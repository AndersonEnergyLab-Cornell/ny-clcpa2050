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
year = 2019
P_df = pd.read_csv('Data/nypopulationden.csv')
countylist = P_df['County'].values
ctname2bus = pd.read_csv('county2bus.csv')
countymap = pd.read_csv('countywithpoint.csv')
V_df = pd.read_csv('Data/Vbycounty.csv')
total = 0
ct_dict = {}
for ct in countylist:
	df_EV = pd.read_csv('EVI-Pro-Lite/OutputData/'+ct+'0.csv')
	df_EV['timestamp'] = pd.to_datetime(df_EV['Unnamed: 0'])
	df_EV.set_index('timestamp', inplace=True)
	df_EV_hourly = df_EV.resample('H').sum()
	df_EV_hourly['EVload'] = df_EV_hourly['home_l1']+df_EV_hourly['home_l2']+df_EV_hourly['work_l1']+df_EV_hourly['work_l2']+df_EV_hourly['public_l2']+df_EV_hourly['public_l3']
	NVehicle = V_df[V_df['County']==ct]['N_Vehicle'].values[0]
	coord = countymap[countymap['NAME']==ct]['nearest_point'].values[0]
	coord_arr = np.fromstring(coord[1:-1], sep=' ')
	Y = df_EV_hourly['EVload'].to_numpy()[0:8760]
	Y = Y/10000*NVehicle*(10/8.24)
	print('Y',Y)
	if ct == 'Erie':
		ct_dict['55'] = 0.5*Y
		ct_dict['57'] = 0.125*Y
		ct_dict['59'] = 0.375*Y
	elif ct == 'Westchester':
		ct_dict['74'] = 0.5*Y
		ct_dict['78'] = 0.5*Y
	else:
		bus = ctname2bus[ctname2bus['NAME'] == ct]['busIdx'].values[0]
		if str(bus) in list(ct_dict.keys()):
			ct_dict[str(bus)] =ct_dict[str(bus)]+ Y
		else:
			ct_dict[str(bus)] = Y
	total = total + Y
print(ct_dict)
ct_list = []
for key,value in ct_dict.items():
	ct_list.append(np.insert(value/1000,0,float(key)))

# ct_list = [[float(k)] + v for k, v in ct_dict.items()]
# ct_array = np.array(ct_list)
# format the numpy array with floating point format specifier
ct_array = np.array(ct_list)
# print(formatted)
ct_array = ct_array
np.savetxt('Load/EVload/EVload_Bus.csv',ct_array,delimiter=',')
plt.plot(total)
plt.show()

	# if len(str(round(coord_arr[1],2)))==5:
	# 	weather = pd.read_csv('Data/NSRDB/weather_'+str(coord_arr[0])+'_'+str(round(coord_arr[1],2))+'0_'+str(year)+'.csv')
	# else:
	# 	weather = pd.read_csv('Data/NSRDB/weather_'+str(coord_arr[0])+'_'+str(round(coord_arr[1],2))+'_'+str(year)+'.csv')
	# x = weather.to_numpy()
	# x = x.astype(float)
	# nrow = 8760
	# drybulb = x[:,10].reshape(int(nrow/24),24)
	# humid = x[:,9].reshape(int(nrow/24),24)
	# windspeed = x[:,8].reshape(int(nrow/24),24)
	# winddirect = x[:,12].reshape(int(nrow/24),24)
	# hrad = x[:,11].reshape(int(nrow/24),24)
	# nrad = x[:,7].reshape(int(nrow/24),24)
	# drad = x[:,6].reshape(int(nrow/24),24)
	# hod = x[:,4].reshape(int(nrow/24),24)
	# t = range(0,365)
	# tme = [math.sin(2*math.pi*x/365) for x in t]
	# tcyclic = np.reshape(tme,(365,1))

	# X = np.hstack((drybulb,humid,windspeed,winddirect,hrad,nrad,drad,hod))
	# # X = np.hstack((drybulb,hod))
	# y = df_EV_hourly['EVload'].to_numpy().reshape(365,24)
	# # plt.scatter(x[:,10],df_EV_hourly['EVload'])
	# # plt.show()
	# # Xy = np.hstack((X,y))
	# # q1 = np.quantile(Xy, 0.25, axis=0)
	# # q3 = np.quantile(Xy, 0.75, axis=0)
	# # iqr = q3 - q1
	# # X = X[~((Xy < q1 - 1.5*iqr) | (Xy > q3 + 1.5*iqr)).any(axis=1)]

	# # # q1 = np.quantile(y, 0.25, axis=0)
	# # # q3 = np.quantile(y, 0.75, axis=0)
	# # # iqr = q3 - q1
	# # y = y[~((Xy < q1 - 1.5*iqr) | (Xy > q3 + 1.5*iqr)).any(axis=1)]

	# X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0, shuffle=True)
	# time_train, time_test, y_train2, y_test2 = train_test_split(tcyclic,y,test_size=0.3, random_state=0, shuffle=True)
	# sc = StandardScaler()
	    


	# X_train = np.hstack((X_train,time_train))
	# X_test = np.hstack((X_test,time_test))

	# X_train = sc.fit_transform(X_train)
	# X_test = sc.transform(X_test)

	# model = MLPRegressor(hidden_layer_sizes = (10,10), solver = 'adam',learning_rate = 'adaptive', activation = 'relu', max_iter = 50000,tol=0.00001).fit(X_train,y_train)
	# model.out_activation_ = 'relu'
	# y_pred = model.predict(X_test)
	# y_trainpred = model.predict(X_train)
	# r2_test = metrics.r2_score(y_test, y_pred)
	# r2_train = metrics.r2_score(y_train, y_trainpred)
	# mse_test = metrics.mean_squared_error(y_test, y_pred)
	# rmse_test = np.sqrt(mse_test)

	# mse_train = metrics.mean_squared_error(y_train, y_trainpred)
	# rmse_train = np.sqrt(mse_train)
	# fig, ax = plt.subplots()
	# ax.scatter(y_test,y_pred)
	# a = range(int(np.min(y_test)), int(np.max(y_test)))
	# ax.plot(a, a,  ls='--', c='k')
	# ax.text(0.25*int(np.max(y_test)), 0.9*int(np.max(y_test)), 'nr2_test = '+str(r2_test), fontsize=10, color='black', ha='center', va='center')
	# # ax.text(0.25*int(np.max(y_test)), 0.7*int(np.max(y_test)), 'nmodel = '+str(Nmodel), fontsize=10, color='black', ha='center', va='center')
	# ax.text(0.25*int(np.max(y_test)), 0.5*int(np.max(y_test)), 'r2_train = '+str(r2_train), fontsize=10, color='black', ha='center', va='center')
	
	# # plt.show()
	# plt.savefig('EVI-Pro-Lite/W2EVplots/'+ct+'.png')
	# plt.close(fig)
	# # save the model to disk
	# filename = 'EVI-Pro-Lite/annWeather2EV/annw2ev_'+ct+'_model.sav'
	# pickle.dump(model, open(filename, 'wb'))
