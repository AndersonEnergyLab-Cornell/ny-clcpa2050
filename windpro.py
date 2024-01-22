import numpy as np
import pandas as pd
import glob
from decimal import *

import os

def get_file_list(directory,year):
    return [f for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f)) and str(year) in f]


for year in range(1980,2020):

	for zone in ['A','B','C','D','E','F','G','H','I','J','K']:
		print(zone)
		if zone == 'H' or zone =='I':
			zonename = 'HI'
		else:
			zonename = zone
		# filenames = glob.glob('RenewableGen/Wind/MERRA_at_WIND_dstadjusted/Zone'+zone+'/*.txt')
		directory = 'RenewableGen/Wind/MERRA_at_WIND_dstadjusted/Zone'+zonename+'/'
		filenames = get_file_list(directory,year)
		lon = np.empty(shape=(len(filenames), 1), dtype=float)
		lat = np.empty(shape=(len(filenames), 1), dtype=float)
		for i in range(len(filenames)):
			if len(filenames[i])>23:
				# print(filenames[i])
				lat[i] = float(filenames[i][11:16])
				lon[i] = float(filenames[i][17:23])

		# lat = '{}'.format(lat.quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
		# lon = '{}'.format(lon.quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
		assig = pd.read_csv('Data/windsolarassignment.csv')
		Zonalassign = assig.loc[assig['zone'] == zone]


		#Wind assignment

		caps = pd.read_csv('Data/zonalcapS2.csv')
		capswind = caps.loc[0,:]
		capzone = capswind[zone]
		# print(capzone)
		windassign = Zonalassign.loc[Zonalassign['Wind']!= 0]
		Wind = np.empty(shape=(len(windassign), 8761), dtype=float)
		for i in range(len(windassign)):
			# print(windassign['lon'].values[i])
			Wind[i,0] = int(windassign['busid'].values[i])
			windlon = windassign['lon'].values[i]
			windlat = windassign['lat'].values[i]
			windcapratio = windassign['Wind'].values[i]
			difflat = lat-windlat
			difflon = lon-windlon
		# print(difflat,difflon)
			dist = np.square(difflon)+np.square(difflat)
			ind = np.argmin(dist)
			la = '{}'.format(Decimal(lat[ind,0]).quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
			lo = '{}'.format(Decimal(lon[ind,0]).quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
			windgen = pd.read_csv('RenewableGen/Wind/MERRA_at_WIND_dstadjusted/Zone'+zonename+'/merrapower_'+str(la)+'_'+str(lo)+'_'+str(year)+'.txt')
			windgen = windgen.fillna(method="ffill")
			# print(windgen)
			Wind[i,1:8761] = windgen['x'].to_numpy()*capzone*windcapratio

			np.savetxt('RenewableGen/Wind/WindData/'+str(year)+'_Wind'+zone+'.csv',Wind,delimiter=',', newline='\n')
		
		# print(windassign.head(5))

	for zone in ['J_OSW','K_OSW']:
		print(zone)
		directory = 'RenewableGen/Wind/MERRA_at_WIND_dstadjusted/Zone'+zonename+'/'
		filenames = get_file_list(directory,year)
		lon = np.empty(shape=(len(filenames), 1), dtype=float)
		lat = np.empty(shape=(len(filenames), 1), dtype=float)
		for i in range(len(filenames)):
			if len(filenames[i])>23:
				print(filenames[i])
				lat[i] = float(filenames[i][11:16])
				lon[i] = float(filenames[i][17:23])
		# lat = '{}'.format(lat.quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
		# lon = '{}'.format(lon.quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
		assig = pd.read_csv('Data/windsolarassignment.csv')
		Zonalassign = assig.loc[assig['zone'] == zone]


		#Wind assignment

		caps = pd.read_csv('Data/zonalcapS2.csv')
		capswind = caps.loc[1,:]
		capzone = capswind[zone[0]]
		# print(capzone)
		windassign = Zonalassign.loc[Zonalassign['Wind']!= 0]
		Wind = np.empty(shape=(len(windassign), 8761), dtype=float)
		for i in range(len(windassign)):
			# print(windassign['lon'].values[i])
			Wind[i,0] = int(windassign['busid'].values[i])
			windlon = windassign['lon'].values[i]
			windlat = windassign['lat'].values[i]
			windcapratio = windassign['Wind'].values[i]
			difflat = lat-windlat
			difflon = lon-windlon
		# print(difflat,difflon)
			dist = np.square(difflon)+np.square(difflat)
			ind = np.argmin(dist)
			la = '{}'.format(Decimal(lat[ind,0]).quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
			lo = '{}'.format(Decimal(lon[ind,0]).quantize(Decimal('.01'), rounding=ROUND_HALF_EVEN))
			windgen = pd.read_csv('RenewableGen/Wind/MERRA_at_WIND_dstadjusted/Zone'+zonename+'/merrapower_'+str(la)+'_'+str(lo)+'_'+str(year)+'.txt')
			windgen = windgen.fillna(method="ffill")
			# print(windgen)
			Wind[i,1:8761] = windgen['x'].to_numpy()*capzone*windcapratio
		np.savetxt('RenewableGen/Wind/WindData/'+str(year)+'_Wind'+zone+'.csv',Wind,delimiter=',', newline='\n')