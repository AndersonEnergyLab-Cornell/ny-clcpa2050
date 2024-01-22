#%%
import numpy as np
import pandas as pd
from smt.sampling_methods import LHS
import random
'''
This script will generate 1000 Latin Hypercube Samples (LHS)
of deeply uncertain system parameters for the Sedento Valley
'''


# create an array storing the ranges of deeply uncertain parameters
DU_factor_limits = np.array([
    [0.95, 5.64], # Temperature increase
    # [0.25, 0.45], # Solar Efficiency
    [0.7, 1.05], # Building electrificationAE
    # [0.7, 1.05], # Building electrificationFI
    # [0.7, 1.05], # Building electrificationJK
    [0.7, 1.05], # EVAE
    # [0.7, 1.05], # EVFI
    # [0.7, 1.05], # EVJK
    [0.6, 1.4], # Wind Capacity
    [0.6, 1.4], # Solar Capacity
    [0.6, 1.4]]) # Battery Capacity
    

# Use the smt package to set up the LHS sampling
sampling = LHS(xlimits=DU_factor_limits)

# We will create 1000 samples
num = 300

# Create the actual sample
x = sampling(num)
# solar_eff_values = [1, 2, 3]
# solar_eff = random.choices(solar_eff_values, k=num)
# solar_eff = np.array(solar_eff)
# solar_eff = np.reshape(solar_eff,(num,1))
stemp = x[:,0]
temp = pd.read_csv('Load/temperature.changes.csv')
dt = temp['temperature_change_deg_C'].values
distances = np.abs(temp['temperature_change_deg_C'].values - stemp[:, np.newaxis])

# find index of closest value for each value in np array
closest_idx = np.argmin(distances, axis=1)

# get corresponding values in column A
closest_values = temp.loc[closest_idx, 'scenario'].values
y = np.zeros([num,1])
print(closest_values)  # [1 3 4]
for i in range(0,num):
    x[i,0] = temp.loc[closest_values[i]-1,'temperature_change_deg_C']
    y[i,0] = temp.loc[closest_values[i]-1,'scenario']
# x[:,1] = np.round(x[:,1],2)
x = np.hstack([x,y])
# save to a csv file
np.savetxt('DU_factors_v3_'+str(num)+'.csv', x, delimiter=',')