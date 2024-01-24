
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source('./wind_to_power.R')
source('./substrRight.R')
sites<-read.csv('Data/RenewableGen/Wind/sites_pcurve_clustermembers.csv')

zones <- c('zoneA','zoneB','zoneC','zoneD','zoneE','zoneF','zoneJ_OSW','zoneK_OSW')
#zones <- c('zoneA')
yr_range <- 1980:2019
for (zone in zones) {
  dat <- list.files(paste('Data/RenewableGen/Wind/NREL_WTK/MERRA_at_WTK_nointerp_LZ/',zone,'/',sep=''))
  siteidlist <- unique(substr(dat,11,22))
  
  z = substrRight(zone,1)
  
  if (zone == 'zoneJ_OSW' | zone == 'zoneK_OSW') {
    z = substrRight(zone,5)
    sites<-read.csv('Data/RenewableGen/Wind/sites_and_zones_offshore.csv')
  }
  #cmemagg is the sum of the clustermembers used to do a weighted average of the power at each wind site.
  cmemagg <- sum(sites$LZ == z)
  
  windpowerallsites <- c()
  for (siteid in siteidlist) {
    lat <- substr(siteid,1,5)
    lon <- substr(siteid,7,12)
    
    windpowerallyears <- c()
    for (yr in yr_range){

      ndx <- which(as.double(lat) == sites$lat & as.double(lon) == sites$lon)
      merra <- read.table(paste('Data/RenewableGen/Wind/NREL_WTK/MERRA_at_WTK_nointerp_LZ/',zone,'/merrawind_',lat,'_',
                                lon,'_',yr,'.txt',sep = ''),sep = '', header = T)
      #Load in stability Coefficients here
      stabcoef <- read.csv(paste("Data/RenewableGen/Wind/NREL_WTK/StabilityCoef/YearlyCoef_LZ/",zone,"/coef_",
                                 lat,'_',lon,'.csv',sep = ''))
      
      interpwind <- merra$x * (100/10)^stabcoef$stabilitycoef
      
      windpower <- wind_to_power(interpwind,sites$PCurveType[ndx])
      write.table(windpower, paste('Data/RenewableGen/Wind/NREL_WTK/MERRA_at_WTK_power_LZ/',zone,'/merrapower_',lat,'_',lon,
                                        '_',as.character(yr),'.txt',sep =''), row.names = F)
      
      windpowerallyears <- c(windpowerallyears,windpower)
    }
    windpowerallsites<-cbind(windpowerallsites,windpowerallyears * sites$clustermembers[ndx]/cmemagg)
  }
  power_aggregate <- rowSums(windpowerallsites)
  write.table(power_aggregate, paste('Data/RenewableGen/Wind/NREL_WTK/MERRA_at_WTK_power_LZ/merrapower_',zone,'_aggregate.txt',sep =''), row.names = F)
}