import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
import pickle
from scipy.stats import norm, kstest
update = 8
allY = 0
totalY = 0
hometype = ['mobile_home','multi-family_with_5plus_units','multi-family_with_2_-_4_units','single-family_attached','single-family_detached']
for ht in hometype:
	df = pd.read_csv('Data/Load/resloadny/update'+str(update)+'/up0'+str(update)+'-ny-'+ht+'.csv')
# df = pd.read_csv('Data/Load/resloadny/update8/up08-ny-single-family_detached.csv')
# df = pd.read_csv('Data/Load/resloadny/update8/up08-ny-single-family_attached.csv')
# df = pd.read_csv('Data/Load/resloadny/update8/up08-ny-multi-family_with_5plus_units.csv')
# df = pd.read_csv('Data/Load/resloadny/update8/up08-ny-multi-family_with_2_-_4_units.csv')
# df = pd.read_csv('Data/Load/resloadny/update8/up08-ny-mobile_home.csv')
	df['timestamp'] = pd.to_datetime(df['timestamp'])
	df.set_index('timestamp', inplace=True)
	Nunits = df['units_represented'].values[1]
	hourly_df = df.resample('H').sum()

	oil_heat = hourly_df['out.fuel_oil.heating.energy_consumption.kwh.savings'].values
	oil_water = hourly_df['out.fuel_oil.hot_water.energy_consumption.kwh.savings'].values
	oil_bkheat = hourly_df['out.fuel_oil.heating_hp_bkup.energy_consumption.kwh.savings'].values

	gas_dryer = hourly_df['out.natural_gas.clothes_dryer.energy_consumption.kwh.savings'].values
	gas_heat = hourly_df['out.natural_gas.heating.energy_consumption.kwh.savings'].values
	gas_water = hourly_df['out.natural_gas.hot_water.energy_consumption.kwh.savings'].values
	gas_roven = hourly_df['out.natural_gas.range_oven.energy_consumption.kwh.savings'].values
	gas_bkheat = hourly_df['out.natural_gas.heating_hp_bkup.energy_consumption.kwh.savings'].values

	propane_dryer = hourly_df['out.propane.clothes_dryer.energy_consumption.kwh.savings'].values
	propane_heat = hourly_df['out.propane.heating.energy_consumption.kwh.savings'].values
	propane_water = hourly_df['out.propane.hot_water.energy_consumption.kwh.savings'].values
	propane_roven = hourly_df['out.propane.range_oven.energy_consumption.kwh.savings'].values

	elec_bkup = hourly_df['out.electricity.heating_hp_bkup.energy_consumption.kwh.savings'].sum()
	elec_heat = hourly_df['out.electricity.heating.energy_consumption.kwh.savings'].sum()
	elec_water = hourly_df['out.electricity.hot_water.energy_consumption.kwh.savings'].sum()

	print('heat:' ,np.sum(oil_heat+gas_heat+propane_heat)/(elec_heat+elec_bkup))
	print('water:', np.sum(oil_water+gas_water+propane_water)/elec_water)
	Y = -hourly_df['out.electricity.total.energy_consumption.kwh.savings']+hourly_df['out.electricity.pv.energy_consumption.kwh']
	YY = -hourly_df['out.electricity.total.energy_consumption.kwh.savings']
	X = oil_heat+oil_water+gas_dryer+gas_heat+gas_water+gas_roven+propane_heat+propane_dryer+propane_water+propane_roven
	print(np.sum(X))
	print(Y.sum())
	X = X/Nunits
	# Y = Y/Nunits
	allY = allY+Y
	totalY = totalY+YY
	coeffs = np.polyfit(X, Y, 2)
	fitted_func = np.poly1d(coeffs)
	# fig, ax = plt.subplots()
	# ax.scatter(X, Y)
	# ax.scatter(X, fitted_func(X), color='red')
	# ax.set_xlabel('Ohter energy (KWh)')
	# ax.set_ylabel('Electricity (KWh)')
	# ax.set_title(ht)
	# plt.savefig('Heat2LoadFit/'+ht+'.png')
	# plt.close(fig)
	# plt.show()
	r2 = r2_score(fitted_func(X), Y)
	print(r2)
	# result = pd.DataFrame(data = {'Y': Y.values,'Y_pred':fitted_func(X).T,'Error':Y.values - fitted_func(X).T})
	# result.to_csv('Heat2LoadFit/Heat2Elec_'+ht+str(update)+'.csv')
	# with open('Heat2LoadFit/coeff_'+ht+str(update)+'.pkl', 'wb') as f:
	# 	pickle.dump(fitted_func, f)
plt.plot(allY)
plt.plot(totalY)
plt.show()

	# np.savetxt('Data/Load/resloadny/Heatload_CT/heatload_'+ht)
	# np.savetxt('Heat2LoadFit/coeff_'+str(update)+'.txt',coeffs)

# mu, std = beta.fit(df['Error'])
# test_stat, p_value = kstest(df['Error'], 'norm', args=(mu, std))
# print('Test statistic:', test_stat)
# print('p-value:', p_value)
# res = stats.probplot(df['Error'], dist="norm", plot=plt)

# # Show the plot
# plt.show()
# from statsmodels.distributions.empirical_distribution import ECDF
# ecdf = ECDF(df['Error'])
# data = df['Error']
# # create an ECDF object
# ecdf = ECDF(data)

# # generate 10 inverse samples from the ECDF
# samples = ecdf(data.min() + (data.max()-data.min())*np.random.random(1))




# from scipy.stats import beta
# import matplotlib.pyplot as plt

# # Generate some random data
# data = 
# X = df['Error']

# # Fit beta distribution to the data
# a, b, loc, scale = beta.fit(data)

# # Plot the histogram of the data and the fitted PDF
# plt.hist(data, density=True, alpha=0.5, bins=50)
# x = np.linspace(-1, 1, 100)
# pdf = beta.pdf(x, a, b, loc=loc, scale=scale)
# plt.plot(x, pdf, 'k-', linewidth=2)
# plt.show()

# from scipy.stats import beta, kstest

# # Generate a sample from a beta distribution


# # Fit a beta distribution to the sample
# params = beta.fit(data)

# # Perform the KS test
# D, p_value = kstest(data, 'beta', args=params)

# print(f"KS test statistic: {D}")
# print(f"p-value: {p_value}")