import numpy as np
import pandas as pd

# df = pd.read_csv('Data/NYVehicle.csv')

# LDVlist = ['CONV','SEDN','SUBN','4DSD','2DSD','ATV','MCY','AMBU','P/SH','TOW','VAN','TAXI','LSV']
# MLDVlist = ['DELV','FLAT','PICK','STAK']


# df1 = df[df['Body Type'].isin(LDVlist)]
# df2 = df[df['Body Type'].isin(MLDVlist)]
# df2 = df2[df2['Unladen Weight']<=4000]

# df_V = pd.concat([df1,df2])
# df_V['County'] = df_V['County'].str.capitalize()
# count_by_county = df_V.groupby('County').size()

# count_by_county.to_csv('Data/Vbycounty.csv')

V_df = pd.read_csv('Data/Vbycounty.csv')
P_df = pd.read_csv('Data/nypopulationden.csv')
countylist = P_df['County'].values
P_df['Population_density'] = P_df['Population_density'].str.replace(',','')
countymap = pd.read_csv('countywithpoint.csv')
year = 2019
# p2d = {'99':31,'499':26,'999':22,'1999':20,'3999':18,'9999':17,'24999':16,'99999':14}
p2d = {'99':35,'499':25,'999':25,'1999':25,'3999':25,'9999':25,'24999':25,'99999':25}
for ct in countylist:
	S_df = pd.DataFrame(columns = ['fleet_size','mean_dvmt','temp_c','pev_type','pev_dist','class_dist','home_access_dist','home_power_dist','work_power_dist','pref_dist','res_charging','work_charging'])
	print(ct)
	# fleetsize = V_df[V_df['County']==ct]['N_Vehicle'].values[0]
	fleetsize = 10000
	print(fleetsize)
	population = float(P_df[P_df['County']==ct]['Population_density'].values[0])
	# population = float(P_df[P_df['County']==ct]['Population_density'])
	
	if population <= 99:
		mean_dvmt = p2d['99']
	elif population >= 100 and population <=499:
		mean_dvmt = p2d['499']
	elif population >= 500 and population <=999:
		mean_dvmt = p2d['999']
	elif population >= 1000 and population <=1999:
		mean_dvmt = p2d['1999']
	elif population >= 2000 and population <=3999:
		mean_dvmt = p2d['3999']
	elif population >= 4000 and population <=9999:
		mean_dvmt = p2d['9999']
	elif population >= 10000 and population <=24999:
		mean_dvmt = p2d['24999']
	elif population >= 25000 and population <=99999:
		mean_dvmt = p2d['99999']
	else:
		mean_dvmt = 10
	temp_c = 10
	pev_type = 'PHEV50'
	pev_dist = 'EQUAL'
	class_dist = 'Sedan'
	home_access_dist = 'HA100'
	home_power_dist = 'Equal'
	work_power_dist = 'MostL2'
	pref_dist = 'Home100'
	res_charging = 'min_delay'
	work_charging = 'min_delay'
	S_df.loc[len(S_df)] = [fleetsize,mean_dvmt,temp_c,pev_type,pev_dist,class_dist,home_access_dist,home_power_dist,work_power_dist,pref_dist,res_charging,work_charging]
	S_df = S_df.reset_index(drop = True)
	S_df.to_csv('EVI-Pro-Lite/inputData/'+ct+'.csv', index=False)

	coord = countymap[countymap['NAME']==ct]['nearest_point'].values[0]
	coord_arr = np.fromstring(coord[1:-1], sep=' ')
	if len(str(round(coord_arr[1],2)))==5:
		weather = pd.read_csv('Data/NSRDB/weather_'+str(coord_arr[0])+'_'+str(round(coord_arr[1],2))+'0_'+str(year)+'.csv')
	else:
		weather = pd.read_csv('Data/NSRDB/weather_'+str(coord_arr[0])+'_'+str(round(coord_arr[1],2))+'_'+str(year)+'.csv')
	weather['date'] = pd.to_datetime(weather[['Year', 'Month', 'Day', 'Hour']])
	df_W = weather[['date','Temperature']]
	df_W = df_W.rename(columns={'Temperature': 'temperature'})
	df_W = df_W.set_index('date')
	df_W = df_W.resample('D').mean()
	df_W.to_csv('EVI-Pro-Lite/inputData/Temp_'+ct+'.csv')
