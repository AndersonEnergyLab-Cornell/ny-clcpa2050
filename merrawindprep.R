#Processing MERRA2 Data
library(ncdf4)
library(abind)
library(lubridate)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


windfiles <- list.files('Data/RenewableGen/MERRA_windv2/')
year_range <- 1980:2019

for (my_yr in year_range) {
  
  #dat_yr <- windfiles[substr(windfiles,28,31) == as.character(my_yr-1) | substr(windfiles,28,31) == as.character(my_yr) | substr(windfiles,28,31) == as.character(my_yr+1)]
  dat_yr <- windfiles[ substr(windfiles,28,31) == as.character(my_yr) | substr(windfiles,28,31) == as.character(my_yr+1)]
  
  #Load up Solar Data Here
  
  #merra_wind_yr <- c()
  #merra_hgt_yr <- c()
  merra_full_time <- c()
  merra_speed_yr <- c()
  for (dat in dat_yr) {
    ncname <- paste('Data/RenewableGen/MERRA_windv2/',dat,sep='')
    merra_sfcwind_nc<-nc_open(ncname)
    merra_lon<-ncvar_get(nc=merra_sfcwind_nc,"lon")
    merra_lat<-ncvar_get(nc=merra_sfcwind_nc,"lat")
    merra_time<-ncvar_get(nc=merra_sfcwind_nc,"time")
    
    #merra_wind<-ncvar_get(nc=merra_sfcwind_nc,"SPEED") #surface_layer_height
    #merra_hgt<-ncvar_get(nc=merra_sfcwind_nc,"HLML")

    merra_vcomp <- ncvar_get(nc=merra_sfcwind_nc,"V10M")
    merra_ucomp <- ncvar_get(nc=merra_sfcwind_nc,"U10M")
    merraspeed <- sqrt(merra_vcomp^2 + merra_ucomp^2)
    
    yr <- substr(dat,28,31)
    mth <- substr(dat,32,33)
    dy <- substr(dat,34,35)
    
    if (!((mth == '02') & (dy == '29'))) {
      merra_speed_yr <- abind(merra_speed_yr,merraspeed, along = 3)
      merra_time_utc<-as.POSIXct(merra_time*60,origin=paste(yr,"-",mth,"-",dy, " ", "00:00:00", sep = ''), tz='UTC')
      merra_full_time <- c(merra_full_time, merra_time_utc)
    }
    #merra_speed_yr <- abind(merra_speed_yr,merraspeed, along = 3)
    #merra_wind_yr <-abind(merra_wind_yr,merra_wind,along=3)
    #merra_hgt_yr <- abind(merra_hgt_yr, merra_hgt, along=3)
    

    
    #merra_time_utc<-as.POSIXct(merra_time*60,origin=paste(yr,"-",mth,"-",dy, " ", "00:00:00", sep = ''), tz='UTC')
    #merra_full_time <- c(merra_full_time, merra_time_utc)
    

    
    #Append the time here?
    #Eh Fuck it. Too much effort
    
    nc_close(merra_sfcwind_nc)
  }
  
  merra_dates <- as.POSIXct(merra_full_time,origin="1970-01-01 00:00:00", tz='UTC')
  merra_dates_est <-format(merra_dates, tz="America/New_York",usetz=TRUE)
  #Load up Temp Data Here
  
  #merra_wind_yr_specific <- merra_wind_yr
  #merra_hgt_yr_specific <- merra_hgt_yr
  
  
  #merra_wind_yr_specific <- merra_wind_yr[,,year(merra_dates_est) == my_yr]
  #merra_hgt_yr_specific <- merra_hgt_yr[,,year(merra_dates_est) == my_yr]
  #merra_speed_yr <- merra_speed_yr[,,!(month(merra_dates) == 2 & day(merra_dates) == 29)]
  
  merra_speed_yr_specific <- merra_speed_yr[,,year(merra_dates_est) == my_yr]

  zones <- c('zoneA','zoneB')
             #,'zoneC','zoneD','zoneE','zoneF','zoneJ_OSW','zoneK_OSW')
  
  #wtklist <- list.files('./NREL_WTK/WTK_testdata')
  for (zone in zones){
    
  
    wtklist <- list.files(paste('Data/RenewableGen/Wind/NREL_WTK/WTK_NYfull/',zone,sep=''))
  
  #for (yr in year_range) {
  #timendx <- year(eratime.vec) == yr
  #era_time_sub <- eratime.vec[timendx]
  #era_ws_wtk<-era_ws[,,timendx]
  #rm(era_ws)
  #era_lat_subset<-era_lat; era_lon_subset<-era_lon
  
    for (fle in wtklist) {
      #Load in NREL data at the given NREL site and year
      #filename <- wtkdatalist[(siteid == substr(wtkdatalist,1,7)) & (as.character(yr) == substr(wtkdatalist,22,25))] 
      #wtk <- read.csv(paste('./NREL_WTK/WTK_testdata/',fle,sep=''))
      wtk <- read.csv(paste('Data/RenewableGen/Wind/NREL_WTK/WTK_NYfull/',zone,'/',fle,sep=''))
      
      wtklat <- as.double(substr(fle,9,13))
      wtklon <- as.double(substr(fle,15,20))
      
      lat_ndx <- which(abs(merra_lat - wtklat) == min(abs(merra_lat - wtklat)))[1]
      lon_ndx <- which(abs(merra_lon - wtklon) == min(abs(merra_lon - wtklon)))[1]
      
      speed_specific <-merra_speed_yr_specific[lon_ndx,lat_ndx,]
  
      coords <- substr(fle,9,20)
      
  
      write.table(speed_specific, paste('Data/RenewableGen/Wind/MERRA_at_WTK_nointerp_LZ/',zone,'/merrawind_',coords,'_',as.character(my_yr),'.txt',sep =''), row.names = F)
    }
  }
  
}