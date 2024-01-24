# -*- coding: utf-8 -*-
"""
Created on Wed Apr 14 14:56:53 2021

@author: Kenji
"""

import pickle
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
import datetime
from datetime import date, timedelta
import sys
from multiprocess import Process, Queue

deltatemp = pd.read_csv('Data/temperature.changes.csv')
# for scenario in range(1,160):
# scenario = int(sys.argv[1])
scenario = 1
print(scenario)
#1980-2019
#2036-2085
dtemp = deltatemp[deltatemp['scenario']==scenario]['temperature_change_deg_C'][scenario-1]
# dtemp = 0
yr_range = range(1998,2020)

    #yr_range = range(2000,2020)
zones = ['A','B','C','D','E','F','G','H','I','J','K']
#zones = ['E','F','G','H','I','J','K']
# zones = ['A']

t = range(0,365)

tempdte = pd.DatetimeIndex(pd.date_range(start="1980-01-01",end="2019-12-31"))
dtemask = (tempdte.month == 2) & (tempdte.day == 29)
dteall = tempdte[~dtemask]

def ErrorSampler(dayte, datets, er):
    #Inputs are the day the error is being sampled for DAYTE
    #Date Time Series for the entire error record DATETS
    #Error from the test of the ANN Model ER   
    n = 11 #Number of days
    datets = pd.DatetimeIndex(datets)
    #pd.DatetimeIndex(err['Date']).year
    dayrange = pd.DatetimeIndex([dayte - timedelta(days=5) - datetime.timedelta(days=x) for x in range(n)]) #Day range of 11 days
    # Here I select for Leap days (If the range contains a leap day, increase the range by 1 and remove it in the if statement)
    negmask = (dayrange.month == 2) & (dayrange.day == 29)
    if sum(negmask) > 0:
        dayrange = pd.DatetimeIndex([dayte - timedelta(days=5) - datetime.timedelta(days=x) for x in range(n+1)]) #Day range of 11 days
        negmask = (dayrange.month == 2) & (dayrange.day == 29)
        dayrange = dayrange[~negmask] 
    ertotal = np.empty((0,24), int)
    for dte in dayrange:
        mask = (dte.month == datets.month) & (dte.month == datets.month)
        ertemp = er[mask]
        er24 = np.reshape(np.array(ertemp),(int(len(ertemp)/24),24))
        ertotal = np.vstack((ertotal,er24))
    ertotal = pd.DataFrame(ertotal)
    # print(ertotal)
    samplederror = ertotal.sample().reset_index(drop=True)
    return samplederror

def findMeanLoad(dayte,datets,load):
    
    datets = pd.DatetimeIndex(datets)
    dte = dayte
    mask = (dte.month == datets.month) & (dte.month == datets.month)
    loadtemp = load[mask]
    load24 = np.reshape(np.array(loadtemp),(int(len(loadtemp)/24),24))
    load_output = np.mean(load24,axis=0)
    return load_output

def zonalextrap(zone):
# for zone in zones:
    err = pd.read_csv("Data/Load/ModelErrorForSampling/err_"+zone+".csv")
    
    tempyears = np.array([])
    dowyears = np.empty((0,3), int)
    timearray = np.array([])
    
    
    sc = pickle.load(open('Data/Load/scaler_'+zone+'.pkl','rb'))
    
    startday = dteall[0]-datetime.timedelta(days=1)
    loadinit = findMeanLoad(startday,err['Date'],err['LoadAct'])
    # print(loadinit)
    #filename = 'annload_K_model.sav'
    filename = 'Data/Load/annload_'+zone+'_model.sav'
    loaded_model = pickle.load(open(filename, 'rb'))
    
    for yr in yr_range:
        
        loadtotal = np.empty((0,24), int)
        
        dow = pd.read_csv("Data/Load/Dates/dayofweek"+str(yr)+".csv")
        temp = np.loadtxt("Data/Load/ZonalTemp_dstfixed_2020/temp_zone"+zone+"_"+str(yr)+".txt", skiprows = 1)
        #dowyears = np.vstack((dowyears,dow[dow.columns[0:3]]))
        dowyears = np.array(dow[dow.columns[0:3]])
        #tempyears = np.hstack((tempyears,temp))
        
        #tempyears_arrange = np.reshape(tempyears,(365*len(yr_range),24))
        tempyears_arrange = dtemp+np.reshape(temp,(365,24))

    
        tme = [math.sin(2*math.pi*x/365) for x in t]#*len(yr_range)
        #tcyclic = np.reshape(tme,(365*len(yr_range),1))
        tcyclic = np.reshape(tme,(365,1))
        
        timevals = np.hstack((tcyclic,dowyears))
    #x = np.hstack((tempyears_arrange[1:len(tempyears_arrange[:,1]),:],
    #                loadyears_arrange[0:len(tempyears_arrange[:,1])-1]))
    
    
    #Sample from the Error HERE
    #Fix the initial load later
    
        errdate = np.reshape(np.array(err['Date']),(int(len(err['Date'])/24),24))[:,0]
    
        for i in range(365):
            print(zone,yr,i)
            s_error = ErrorSampler(dteall[i], err['Date'], err['Error'])
            
            # Here we add on the sampled error to the load before running it through the model
            loadfit = loadinit #+ s_error
            # print(np.mean(np.array(loadfit)))
            if np.mean(np.array(loadfit)) > 2100 and zone == 'A':
                loadfit = loadfit/np.mean(np.array(loadfit))*2100
                print(loadfit)
            loadfit = np.reshape(np.array(loadfit),(24,))
            tempfit = tempyears_arrange[i,:]
            #Scale the Data here
            varinput = np.hstack((tempfit,loadfit))
            varinput = sc.transform(np.reshape(varinput,(1,48)))
            varinput = np.reshape(varinput,(48,))
            dowfit = dowyears[i,:]
            #loadfit = np.reshape(np.array(loadfit),(24,))
            #X_input = np.hstack((tempfit,loadfit,tcyclic[i],dowfit))
            X_input = np.hstack((varinput,tcyclic[i],dowfit))
            X_input = np.reshape(X_input,(1,52))
            Y_output = loaded_model.predict(X_input)
            loadinit = Y_output
            
            saveload = np.array(Y_output+s_error)
            loadtotal = np.append(loadtotal,saveload)
       
        #Save a yearly output here
        loadfinal = pd.DataFrame(loadtotal)
        loadfinal.to_csv('Data/Load/LoadbyScenario/loadex_'+zone+'_'+str(yr)+'_'+str(scenario)+'.csv', index = False)

if __name__ == '__main__':
    # create a process
    processes = [Process(target=zonalextrap, args=(zone,)) for zone in zones]
    for process in processes:
        process.start()
    # wait for all processes to complete
    for process in processes:
        process.join()
    # report that all tasks are completed
    print('Done', flush=True)
