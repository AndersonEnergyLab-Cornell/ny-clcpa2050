import EVIProLite_LoadPlotting
import numpy as np
import pandas as pd

P_df = pd.read_csv('../NYpopulationdentemp.csv')
countylist = P_df['County'].values

for ct in countylist:
	EVIProLite_LoadPlotting.run("./InputData/"+ct+".csv","./InputData/Temp_"+ct+".csv","mHBTSyCcWL8bvEGoBNuHHrqNOUPgeZ0wA0ZIc5Ab",ct)

