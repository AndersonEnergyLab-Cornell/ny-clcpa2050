#Processing MERRA2 Data
library(ncdf4)
library(abind)
library(lubridate)
#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
srange <- 1:159
scenario2 <-1
thermalcoeff <- 0.0026
for (scenario in srange){
  
#scenario = 0
  deltatemp = read.csv('Data/temperature.changes.csv')
  deltat = deltatemp[scenario,2]
  #deltat = 0
  solarfiles <- list.files('Data/RenewableGen/MERRA2radiation/')
  dat_yr <- solarfiles[substr(solarfiles,28,31) == as.character(2006) | substr(solarfiles,28,31) == as.character(2007) ]
  
  mths <- c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')
  #Load up Solar Data Here
  
  merra_sun_yr <- c()
  for (dat in dat_yr) {
    ncname <- paste('Data/RenewableGen/MERRA2radiation/',dat,sep='')
    merra_solar_nc<-nc_open(ncname)
    merra_lon<-ncvar_get(nc=merra_solar_nc,"lon")
    merra_lat<-ncvar_get(nc=merra_solar_nc,"lat")
    merra_sun<-ncvar_get(nc=merra_solar_nc,"SWGDN")
    
    merra_sun_yr <-abind(merra_sun_yr,merra_sun,along=3)
    #Append the time here?
    #Eh Fuck it. Too much effort
    
    nc_close(merra_solar_nc)
  }
  
  
  
  
  #Load up Temp Data Here
  
  tempfiles <- list.files('Data/RenewableGen/MERRA2temp/')
  temp_yr <- tempfiles[substr(tempfiles,28,31) == as.character(2006) | substr(tempfiles,28,31) == as.character(2007)]
  
  merra_temp_yr <- c()
  merra_full_time <- c()
  for (dat in temp_yr) {
    ncname <- paste('Data/RenewableGen/MERRA2temp/',dat,sep='')
    merra_temp_nc<-nc_open(ncname)
    temp_lon<-ncvar_get(nc=merra_temp_nc,"lon")
    temp_lat<-ncvar_get(nc=merra_temp_nc,"lat")
    merra_temp<-ncvar_get(nc=merra_temp_nc,"T2M")
    merra_time<-ncvar_get(nc=merra_temp_nc,"time")
    yr <- substr(dat,28,31)
    mth <- substr(dat,32,33)
    dy <- substr(dat,34,35)
    merra_time_utc<-as.POSIXct(merra_time*60,origin=paste(yr,"-",mth,"-",dy, " ", "00:00:00", sep = ''), tz='UTC')
    
    merra_full_time <- c(merra_full_time, merra_time_utc)
    merra_temp_yr <-abind(merra_temp_yr,merra_temp,along=3)
    #Append the time here?
    #Eh Fuck it. Too much effort
    
    nc_close(merra_temp_nc)
  }
  
  merra_dates <- as.POSIXct(merra_full_time,origin="1970-01-01 00:00:00", tz='UTC')
  merra_dates_est <-format(merra_dates, tz="America/New_York",usetz=TRUE)
  
  
  
  
  merra_sun_yr_2006 <- merra_sun_yr[,,year(merra_dates_est) == 2006]
  merra_temp_yr_2006 <-merra_temp_yr[,,year(merra_dates_est) == 2006]
  
  
  year_range <- 2006
  
  Ct <-(46-20)/(0.8*1000)
  # 46 is the assumed NOCT (Normal Operating Cell Temperature)
  
  sinddatalist <- list.files('Data/RenewableGen/Solar/SINDset/SIND_hourly_clean/')
  
  mthdays <- c(31,28,31,30,31,30,31,31,30,31,30,31)
  
  for (fle in sinddatalist) {
    #Load in NREL data at the given NREL site and year
    #filename <- wtkdatalist[(siteid == substr(wtkdatalist,1,7)) & (as.character(yr) == substr(wtkdatalist,22,25))] 
    sind <- read.csv(paste('Data/RenewableGen/Solar/SINDset/SIND_hourly_clean/',fle,sep=''))
    
    sindlat <- as.double(substr(fle,7,11))
    sindlon <- as.double(substr(fle,13,18))
    
    lat_ndx <- which(abs(merra_lat - sindlat) == min(abs(merra_lat - sindlat)))[1]
    lon_ndx <- which(abs(merra_lon - sindlon) == min(abs(merra_lon - sindlon)))[1]
    
    incident_specific <- merra_sun_yr_2006[lon_ndx,lat_ndx,]
    temp_specific <- merra_temp_yr_2006[lon_ndx,lat_ndx,] - 273.15 #Converting Kelvin to Celcius
    temp_specific <- temp_specific + deltat
    solar_power <- (incident_specific/1000)*(1-thermalcoeff*(temp_specific+Ct*incident_specific-25))
    #Thermal Loss Coeff c(0.0037, 0.0045)
  
    coords <- substr(fle,7,18)
    
    coef_full_yr <- c()
    for (i in 1:12) {
      avgmonth_pcoef <- c()
      
      lat <- sindlat
      lon <- sindlon
      #RIGHT HERE WE USE PMIN TO CAP THE CORRECTION FACTOR AT 2 (or double)
      #sind$correction <- pmin(sind$UnitPower/(solar_power+1E-16) * !(solar_power == 0),2) #THIS COMMENTED OUT SECTION IS FOR MULTIPLICATIVE SCALING FACTOR
      sind$correction <- sind$UnitPower - solar_power #Now we are using an additive scaling factor
      sind$Hour <- hour(as.POSIXlt(sind$Time, format="%m/%d/%y %H:%M"))
        
      df <- sind[month(as.POSIXlt(sind$Time, format="%m/%d/%y %H:%M")) == i,]
      #df$Hour <- hour(as.POSIXlt(sind$Time, format="%m/%d/%y %H:%M"))
      #Aggregate each months correction factor
      mthly_pcoef<- aggregate(df$correction, by = list(df$Hour), FUN = mean)
      #Replicate the correction factor by the number of days in each month
      temp<-rep(mthly_pcoef$x,mthdays[i])
      #Concatenate all months for form a year of correction factors
      coef_full_yr <- c(coef_full_yr,temp)
      #Write the individual months to a csv for plotting
      write.csv(mthly_pcoef$x,paste("Data/RenewableGen/Solar/SINDset/CorrectionFactorAdditive/coef_",lat,'_',lon,'_',mths[i],'_',scenario,'_',scenario2,'.csv',sep = ''))
      
    }
    #Write the overall year for calculations
    dat<-data.frame(coef_full_yr)
    colnames(dat) <- c('correctioncoef')
    write.csv(dat,paste("Data/RenewableGen/Solar/SINDset/CorrectionFactorAdditive/coef_",lat,'_',lon,'_',scenario,'_',scenario2,'.csv',sep = ''))
    
  }

}
  
  
  



