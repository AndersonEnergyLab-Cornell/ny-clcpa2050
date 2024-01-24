#Processing MERRA2 Data
library(ncdf4)
library(abind)
library(lubridate)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
deltatemp = read.csv(file = 'Data/temperature.changes.csv')
srange <- 1:159
scenario2 <-1
thermalcoeff <- 0.0026
for (scenario in srange){

  
    deltat = deltatemp[scenario,2]
    #deltat = 0
    solarfiles <- list.files('Data/RenewableGen/MERRA2radiation/')
    loadzones <- c('A','B','C','D','E','F','G','HI','J','K')
    sindcoords <- read.csv('Data/RenewableGen/Solar/sindcoords.csv')
    yr_range <- 1980:2019
    for (yr in yr_range){
      dat_yr <- solarfiles[substr(solarfiles,28,31) == as.character(yr) | substr(solarfiles,28,31) == as.character(yr+1) ]
      

      
      merra_sun_yr <- c()
      for (dat in dat_yr) {

        ncname <- paste('Data/RenewableGen/MERRA2radiation/',dat,sep='')
        merra_solar_nc<-nc_open(ncname)
        merra_lon<-ncvar_get(nc=merra_solar_nc,"lon")
        merra_lat<-ncvar_get(nc=merra_solar_nc,"lat")
        merra_sun<-ncvar_get(nc=merra_solar_nc,"SWGDN")
        
        merra_sun_yr <-abind(merra_sun_yr,merra_sun,along=3)

        
        nc_close(merra_solar_nc)
      }
      

      
      tempfiles <- list.files('Data/RenewableGen/MERRA2temp/')
      temp_yr <- tempfiles[substr(tempfiles,28,31) == as.character(yr) | substr(tempfiles,28,31) == as.character(yr+1)]
      
      merra_temp_yr <- c()
      merra_full_time <- c()
      for (dat in temp_yr) {
        ncname <- paste('Data/RenewableGen//MERRA2temp/',dat,sep='')
        ncname <- paste('Data/RenewableGen/MERRA2temp/',dat,sep='')
        merra_temp_nc<-nc_open(ncname)
        temp_lon<-ncvar_get(nc=merra_temp_nc,"lon")
        temp_lat<-ncvar_get(nc=merra_temp_nc,"lat")
        merra_temp<-ncvar_get(nc=merra_temp_nc,"T2M")
        merra_time<-ncvar_get(nc=merra_temp_nc,"time")
        yer <- substr(dat,28,31)
        mth <- substr(dat,32,33)
        dy <- substr(dat,34,35)
        merra_time_utc<-as.POSIXct(merra_time*60,origin=paste(yer,"-",mth,"-",dy, " ", "00:00:00", sep = ''), tz='UTC')
        
        merra_full_time <- c(merra_full_time, merra_time_utc)
        merra_temp_yr <-abind(merra_temp_yr,merra_temp,along=3)

        
        nc_close(merra_temp_nc)
      }
      
      merra_dates <- as.POSIXct(merra_full_time,origin="1970-01-01 00:00:00", tz='UTC')
      merra_dates_est <-format(merra_dates, tz="America/New_York",usetz=TRUE)
      

    
    
    
    
      merra_sun_yr_specific <- merra_sun_yr[,,year(merra_dates_est) == yr]
      merra_dates_yr <- merra_dates_est[year(merra_dates_est) == yr]
      merra_sun_yr_specific <- merra_sun_yr_specific[,,!(month(merra_dates_yr) == 2 & day(merra_dates_yr) == 29)]
      merra_temp_yr_specific <-merra_temp_yr[,,year(merra_dates_est) == yr]
      merra_temp_yr_specific <- merra_temp_yr_specific[,,!(month(merra_dates_yr) == 2 & day(merra_dates_yr) == 29)]
      
      
      # SOLAR POWER CALCULATION
      Ct <-(46-20)/(0.8*1000)
    # 46 is the assumed NOCT (Normal Operating Cell Temperature)
      #thermalcoeff <- 0.0045
      sinddatalist <- list.files('Data/RenewableGen/Solar/SINDset/SIND_hourly_clean')
    

      for (fle in sinddatalist) {
        #Load in NREL data at the given NREL site and year
        #filename <- wtkdatalist[(siteid == substr(wtkdatalist,1,7)) & (as.character(yr) == substr(wtkdatalist,22,25))] 
        sind <- read.csv(paste('Data/RenewableGen/Solar/SINDset/SIND_hourly_clean/',fle,sep=''))
        
        sindlat <- as.double(substr(fle,7,11))
        sindlon <- as.double(substr(fle,13,18))
        
        loadzone<-sindcoords$LZ[sindlat == sindcoords$lat & sindlon == sindcoords$lon]
        
        lat_ndx <- which(abs(merra_lat - sindlat) == min(abs(merra_lat - sindlat)))[1]
        lon_ndx <- which(abs(merra_lon - sindlon) == min(abs(merra_lon - sindlon)))[1]
        
        biasfix <- read.csv(paste('Data/RenewableGen/Solar/SINDset/CorrectionFactorAdditive/coef_',sindlat,'_',sindlon,'_',scenario,'_',scenario2,'.csv',sep = ''))
        correction <- biasfix$correctioncoef
        
        incident_specific <- merra_sun_yr_specific[lon_ndx,lat_ndx,]
        temp_specific <- merra_temp_yr_specific[lon_ndx,lat_ndx,] - 273.15 #Converting Kelvin to Celcius
        temp_specific <- temp_specific + deltat
        solar_power <- (incident_specific/1000)*(1-thermalcoeff*(temp_specific+Ct*incident_specific-25))

        coords <- substr(fle,7,18)

        correctedval <- pmin(pmax(solar_power + correction,0),1)
        if (!file.exists(paste('Data/RenewableGen/Solar/MERRA_at_SIND/Scenario',scenario,'_',scenario2,'/zone',loadzone,sep =''),recursive = TRUE)) {
          dir.create(paste('Data/RenewableGen/Solar/MERRA_at_SIND/Scenario',scenario,'_',scenario2,'/zone',loadzone,sep =''),recursive = TRUE)
        }
        write.table(correctedval, paste('Data/RenewableGen/Solar/MERRA_at_SIND/Scenario',scenario,'_',scenario2,'/zone',loadzone,'/merrabiascorrected_',coords,'_',as.character(yr),'.txt',sep =''), row.names = F)

      }
    
    }

}


