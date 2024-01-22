import numpy as np
import pandas as pd
import glob
from decimal import *


assig = pd.read_csv('Data/windsolarassignment.csv')
caps = pd.read_csv('Data/zonalcapS2.csv')
capsto= caps.loc[7,:]
result = np.array([])
for zone in ['A','B','C','D','E','F','G','H','I','J','K']:
	Zonalassign = assig.loc[assig['zone'] == zone]
	capzone = capsto[zone]
	stoassign = Zonalassign.loc[Zonalassign['Storage']!= 0]
	Storage = np.empty(shape=(len(stoassign), 2), dtype=float)
	for i in range(len(stoassign)):
		Storage[i,0] = int(stoassign['busid'].values[i])
		Storage[i,1] = int(capzone*stoassign['Storage'].values[i])

		np.savetxt('Data/StorageData/StorageAssignment_'+zone+'.csv',Storage,delimiter=',',newline='\n')
	result = np.vstack((result, Storage)) if result.size else Storage
result = np.vstack((result,np.array([38,1170])))
np.savetxt('Data/StorageData/StorageAssignment.csv',result,delimiter=',',newline='\n')