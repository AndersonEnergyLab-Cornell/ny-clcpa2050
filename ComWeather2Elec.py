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
from pathlib import Path
from scipy.stats import zscore
from scipy import stats

tracttable = pd.read_csv('Data/spatial_tract_lookup_table.csv')
tt = tracttable[tracttable['state_abbreviation'] == 'NY']
counties = tt['nhgis_county_gisjoin'].unique()



for ct in counties:
	print(ct)
	weather = pd.read_csv('Data/Load/comloadny/weather/'+ct+'_2018.csv')
# weather = pd.read_csv('Data/Load/resloadny/weather/G3600010_tmy3.csv')
	weather['date_time'] = pd.to_datetime(weather['date_time'])
	weather['hour_of_day'] = weather['date_time'].dt.hour
	ct = 'g'+ct[1:]
	elecload = np.loadtxt('Data/Load/comloadny/FittedElecLoad/FittedElecLoad_'+ct+'.txt')
	
	x = weather.to_numpy()
	x = x[:,1:]
	x = x.astype(float)
	drybulb = x[:,0].reshape(365,24)
	humid = x[:,1].reshape(365,24)
	windspeed = x[:,2].reshape(365,24)
	winddirect = x[:,3].reshape(365,24)
	hrad = x[:,4].reshape(365,24)
	nrad = x[:,5].reshape(365,24)
	drad = x[:,6].reshape(365,24)
	hod = x[:,7].reshape(365,24)
	t = range(0,365)
	tme = [math.sin(2*math.pi*x/365) for x in t]
	tcyclic = np.reshape(tme,(365,1))

	X = np.hstack((drybulb,humid,windspeed,winddirect,hrad,nrad,drad,hod))
	y = -elecload[0:8760].reshape(365,24)

	# Xy = np.hstack((X,y))
	# q1 = np.quantile(Xy, 0.25, axis=0)
	# q3 = np.quantile(Xy, 0.75, axis=0)
	# iqr = q3 - q1
	# X = X[~((Xy < q1 - 1.5*iqr) | (Xy > q3 + 1.5*iqr)).any(axis=1)]

	# # q1 = np.quantile(y, 0.25, axis=0)
	# # q3 = np.quantile(y, 0.75, axis=0)
	# # iqr = q3 - q1
	# y = y[~((Xy < q1 - 1.5*iqr) | (Xy > q3 + 1.5*iqr)).any(axis=1)]

	X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0, shuffle=True)
	time_train, time_test, y_train2, y_test2 = train_test_split(tcyclic,y,test_size=0.3, random_state=0, shuffle=True)
	sc = StandardScaler()
	    


	X_train = np.hstack((X_train,time_train))
	X_test = np.hstack((X_test,time_test))

	# X_train = sc.fit_transform(X_train)
	# X_test = sc.transform(X_test)

	model = MLPRegressor(hidden_layer_sizes = (50), solver = 'adam',learning_rate = 'adaptive', activation = 'relu', max_iter = 50000,tol=0.0001).fit(X_train,y_train)
	model.out_activation_ = 'relu'
	y_pred = model.predict(X_test)
	y_trainpred = model.predict(X_train)
	r2_test = metrics.r2_score(y_test, y_pred)
	r2_train = metrics.r2_score(y_train, y_trainpred)
	mse_test = metrics.mean_squared_error(y_test, y_pred)
	rmse_test = np.sqrt(mse_test)

	mse_train = metrics.mean_squared_error(y_train, y_trainpred)
	rmse_train = np.sqrt(mse_train)
	fig, ax = plt.subplots()
	ax.scatter(y_test,y_pred)
	a = range(int(np.min(y_test)), int(np.max(y_test)))
	ax.plot(a, a,  ls='--', c='k')
	ax.text(0.25*int(np.max(y_test)), 0.9*int(np.max(y_test)), 'r2_test = '+str(r2_test), fontsize=10, color='black', ha='center', va='center')
	# ax.text(0.25*int(np.max(y_test)), 0.7*int(np.max(y_test)), 'nmodel = '+str(Nmodel), fontsize=10, color='black', ha='center', va='center')
	ax.text(0.25*int(np.max(y_test)), 0.5*int(np.max(y_test)), 'r2_train = '+str(r2_train), fontsize=10, color='black', ha='center', va='center')
	
	# plt.show()
	plt.savefig('Data/Load/comloadny/W2Eplots/'+ct+'.png')
	plt.close(fig)
	# save the model to disk
	filename = 'Data/Load/comloadny/annWeather2Elec/annw2e_'+ct+'_model.sav'
	pickle.dump(model, open(filename, 'wb'))





