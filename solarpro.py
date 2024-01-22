import numpy as np
import pandas as pd
import glob
from decimal import *

import os

def get_file_list(directory,year):
    return [f for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f)) and str(year) in f]

# for scenario in [47,52,107,90,158,134,87,82,20,99,27,23,54,157,55,108,111,132,155,94]:
for scenario in range(1,160):
	for year in range(1998,2020):
		for zone in ['A','B','C','E','F','G','H','I','J','K']:

			if zone == 'H' or zone =='I':
				zonename = 'HI'
			elif zone == 'K':
				zonename = 'J'
			elif zone == 'D':
				zonename = 'E'
			else:
				zonename = zone
			print(zone)
			directory = 'RenewableGen/Solar/MERRA_at_SIND_dstadjusted/Scenario'+str(scenario)+'/zone'+zonename+'/'
			# print(directory)
			filenames = get_file_list(directory,year)
			# print(filenames)
			lon = np.empty(shape=(len(filenames), 1), dtype=float)
			lat = np.empty(shape=(len(filenames), 1), dtype=float)
			yr = np.empty(shape=(len(filenames), 1), dtype=float)
			for i in range(len(filenames)):
				if len(filenames[i])>23:
					lat[i] = float(filenames[i][19:24])
					lon[i] = float(filenames[i][25:31])
					yr[i] = float(filenames[i][33:36])

			# lat = '{}'.format(lat.quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
			# lon = '{}'.format(lon.quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
			assig = pd.read_csv('Data/windsolarassignment.csv')
			Zonalassign = assig.loc[assig['zone'] == zone]


			#Wind assignment

			caps = pd.read_csv('Data/zonalcapS2.csv')
			capswind = caps.loc[6,:]
			capzone = capswind[zone]
			# print(capzone)
			windassign = Zonalassign.loc[Zonalassign['UPV']!= 0]
			Wind = np.empty(shape=(len(windassign), 8761), dtype=float)
			for i in range(len(windassign)):
				# print(windassign['lon'].values[i])
				Wind[i,0] = int(windassign['busid'].values[i])
				windlon = windassign['lon'].values[i]
				windlat = windassign['lat'].values[i]
				windcapratio = windassign['UPV'].values[i]
				difflat = lat-windlat
				difflon = lon-windlon
			# print(difflat,difflon)
				dist = np.square(difflon)+np.square(difflat)
				ind = np.argmin(dist)
				la = '{}'.format(Decimal(lat[ind,0]).quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
				lo = '{}'.format(Decimal(lon[ind,0]).quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
				windgen = pd.read_csv('RenewableGen/Solar/MERRA_at_SIND_dstadjusted/Scenario'+str(scenario)+'/zone'+zonename+'/merrabiascorrected_'+str(la)+'_'+str(lo)+'_'+str(year)+'.txt')
				windgen = windgen.fillna(method="ffill")
				# print(windgen)
				Wind[i,1:8761] = windgen['x'].to_numpy()*capzone*windcapratio
			directory = 'RenewableGen/Solar/SolarData/Scenario'+str(scenario)

			if not os.path.exists(directory):
				os.makedirs(directory)
			np.savetxt('RenewableGen/Solar/SolarData/Scenario'+str(scenario)+'/'+str(year)+'_SolarUPV'+zone+'.csv',Wind,delimiter=',', newline='\n')

		#['A','B','C','E','F','G','H','I','J']:


		for zone in ['A','B','C','D','E','F','G','H','I','J','K']:
			print(zone)
			if zone == 'H' or zone =='I':
				zonename = 'HI'
			elif zone == 'K':
				zonename = 'J'
			elif zone == 'D':
				zonename = 'E'
			else:
				zonename = zone
			directory = 'RenewableGen/Solar/MERRA_at_SIND_dstadjusted/Scenario'+str(scenario)+'/zone'+zonename+'/'
			filenames = get_file_list(directory,year)
			# print(filenames)
			lon = np.empty(shape=(len(filenames), 1), dtype=float)
			lat = np.empty(shape=(len(filenames), 1), dtype=float)
			for i in range(len(filenames)):
				if len(filenames[i])>23:
					# print(filenames[i])
					lat[i] = float(filenames[i][19:24])
					lon[i] = float(filenames[i][25:31])
			


			# lat = '{}'.format(lat.quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
			# lon = '{}'.format(lon.quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
			assig = pd.read_csv('Data/windsolarassignment.csv')
			Zonalassign = assig.loc[assig['zone'] == zone]


			#Wind assignment

			caps = pd.read_csv('Data/zonalcapS2.csv')
			capswind = caps.loc[5,:]
			capzone = capswind[zone]
			# print(capzone)
			windassign = Zonalassign.loc[Zonalassign['DPV']!= 0]
			# print(windassign)
			Wind = np.empty(shape=(len(windassign), 8761), dtype=float)
			for i in range(len(windassign)):
				# print(windassign['lon'].values[i])
				Wind[i,0] = int(windassign['busid'].values[i])
				windlon = windassign['lon'].values[i]
				windlat = windassign['lat'].values[i]
				windcapratio = windassign['DPV'].values[i]
				difflat = lat-windlat
				difflon = lon-windlon
			# print(difflat,difflon)
				dist = np.square(difflon)+np.square(difflat)
				# print(dist)
				ind = np.argmin(dist)
				la = '{}'.format(Decimal(lat[ind,0]).quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
				lo = '{}'.format(Decimal(lon[ind,0]).quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
				windgen = pd.read_csv('RenewableGen/Solar/MERRA_at_SIND_dstadjusted/Scenario'+str(scenario)+'/zone'+zonename+'/merrabiascorrected_'+str(la)+'_'+str(lo)+'_'+str(year)+'.txt')
				windgen = windgen.fillna(method="ffill")
				# print(windgen)
				Wind[i,1:8761] = windgen['x'].to_numpy()*capzone*windcapratio
			directory = 'RenewableGen/Solar/SolarData/Scenario'+str(scenario)

			if not os.path.exists(directory):
				os.makedirs(directory)
			np.savetxt('RenewableGen/Solar/SolarData/Scenario'+str(scenario)+'/'+str(year)+'_SolarDPV'+zone+'.csv',Wind,delimiter=',', newline='\n')