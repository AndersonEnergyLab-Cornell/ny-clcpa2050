# ny-clcpa2050
This Github repository holds the code and sample data for the Climate Leadership and Community Protection Act (CLCPA) climate-energy policy analysis for the New York State. For the full dataset, please refer to the Data section below. 


## Table of Contents
- [Datasetandtoolkits](#Dataset and toolkits)
- [Usage](#Usage)
- [Acknowledgement](#Acknowledgement)


## Dataset and toolkits

The simulation used the following Dataset and toolkits to assist the analysis:

- Policy Data: CLCPA Scoping plan [https://climate.ny.gov/resources/scoping-plan/]
- Modern-Era Retrospective analysis for Research and Applications, Version 2 [https://gmao.gsfc.nasa.gov/reanalysis/MERRA-2/]
- Solar Integration National Dataset Toolkit [https://www.nrel.gov/grid/sind-toolkit.html]
- Wind Integration National Dataset Toolkit [https://www.nrel.gov/grid/wind-toolkit.html]
- NYISO Load Data [https://www.nyiso.com/load-data]
- Open Source NYS Power Grid Data [https://github.com/AndersonEnergyLab-Cornell/NYgrid]
- Eletrified Load Data
    - ResStock Analysis Tool [https://www.nrel.gov/buildings/resstock.html]
    - ComStock Analysis Tool [https://comstock.nrel.gov/]
    - Electric Vehicle Infrastructure Projection Tool (EVI-Pro) Lite [https://afdc.energy.gov/evi-pro-lite]

## Usage
This repo only contains sample data. For full data access, please refer to the Dataset and toolkits section. 
### Main scripts for dcopf simulations
1. Baseline Case :
    - Mainbase.m has baseline dc-opf analysis setup
    - Mainbasecaller.m sets the parameters for baseline 

2.	Deep Uncertain Cases 
    - Main.m has dcopf for 300 scenarios
    - Maincaller.m reads ‘DU_factors_300.csv’ to setup the 300 scenarios
### Scripts for wind, solar data processing

1. Solar (RenewableGen/Solar):
    - solar_correction_estimation.R: change scenario and templossefficiency 
    - merra2solar.R: change scenario and templossefficiency
    - solarpro.py: read in MERRA_at_SIND_dstadjusted; zonecap.csv, windsolarassignment.csv (wind solar cap for each bus)
2. Wind (Path: RenewableGen/Wind):
    - merrawindprep.R: generates wind speed
    - stability_coeff_estimation_lz.R: generates stability coef
    - windinterp_and_converttopower.R: converts wind speed to unit power for each location
    - windpro.py: read in MERRA_at_WIND_dstadjusted; zonecap.csv, windsolarassignment.csv (wind solar cap for each bus)generates zonal wind time series data for each bus

### Scripts for Load
1. Baselineload (Code under Load folder)
    - test2050.py: get zonal load for each scenario each year saved in LoadbyScenario
    - distload.m: distribute zonal load to each bus, saved as simload for different scenarios and year

2.	Commercial load
    - comloadny has the commercial load data from NREL(with processing) and the some fitted params for ANN
    - ComExtrapH2E.py directly assign the electric load saving for each type by county based on the sqft of that county vs sqft of the state. This is because Heat load saving data is not available by county. So we directly disaggregate the electric load 
    - ComWeather2Elec.py Fits an ANN model to map the weather data to electric load. The model is fitted for each county
    - Comextrapelecload.py takes the NSRDB data and put it through the ann model to predict electric load. The load is then mapped to each bus

3.	Residential load
    - resloadny has the residential load data from NREL(with processing) and the some fitted params for ANN
    - Heat2LoadFit.py. use a update from NREL data to fit the heat consumption (saving) to electric saving on the state level for each type
    - ExtrapH2E.py use the fitted model to convert heat consumption from the baseline model for each county and each type
    - Weather2Elec.py fits an ANN model to map the weather data to electric load. The model is fitted for each county 
    - Extrapelecload.py takes the NSRDB data and put it through the ann model to predict electric load. The load is then mapped to each bus 

4.	EV load
    - EVI-Pro-Lite has the API to download data from NREL using main.py
    - cleanVehicle.py process the NY vehicle data and prepare for the API download from NREL EVI-Pro-Lite
    - coord2county.py takes GIS data and generates countywithpoint.csv
    - EVdataprocess.py takes the NREL EVI-Pro-Lite/OutputData to generate the EVload 

### Transmission lines
- Processclimatefactor.m: takes in windspeed, solar rad and temperature 


###	Other Utility:
- Make_LHS.py: Latin hypercube sampling



## Acknowledgement
Scripts for wind, solar data processing are adapted from:
Kenji Doering, C Lindsay Anderson, Scott Steinschneider, Evaluating the intensity, duration and frequency of flexible energy resources needed in a zero-emission, hydropower reliant power system, Oxford Open Energy, Volume 2, 2024, oiad003, [https://doi.org/10.1093/ooenergy/oiad003]
