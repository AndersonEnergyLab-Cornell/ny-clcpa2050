library(lubridate)
library(dplyr)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

zones <- c('zoneA','zoneB','zoneC','zoneD','zoneE','zoneF','zoneJ_OSW','zoneK_OSW')

for (zone in zones) {
  
  wtkdata <- list.files(paste('Data/RenewableGen/Wind/NREL_WTK/WTK_NYfull/',zone,'/',sep=''))
  
  yr_range <- c("2007","2008","2009","2010","2011","2012")
  mths <- c("Jan","Feb","Mar", "Apr", "May", "Jun","Jul","Aug","Sep","Oct","Nov","Dec")
  mthdays <- c(31,28,31,30,31,30,31,31,30,31,30,31)
  siteidlist <- unique(substr(wtkdata,1,7))
  #coef_full_yr <- c()
  for (siteid in siteidlist) {
    
    wtkdatalist<-wtkdata[substr(wtkdata,1,7) == siteid]
    
    #lat <- substr(fl,9,13)
    #lon <- substr(fl,15,20)
    coef_full_yr <- c()
    for (i in 1:12) {
      avgmonth_pcoef <- c()
      for (yr in yr_range){
        
        wtk_yr<- wtkdatalist[substr(wtkdatalist,22,25) == yr]
        lat <- substr(wtk_yr,9,13)
        lon <- substr(wtk_yr,15,20)
        #era <- read.table(paste('../WindData/NREL_WTK/ERA_at_WTK_nointerp/era_',
        #                        lat,'_',lon,'_',yr,'.txt',sep = ''),sep = '', header = T)
        merra <- read.table(paste('Data/RenewableGen/Wind/NREL_WTK/MERRA_at_WTK_nointerp_LZ/',zone,'/merrawind_',lat,'_',
                                  lon,'_',yr,'.txt',sep = ''),sep = '', header = T)
        wtk <- read.csv(paste('Data/RenewableGen/Wind/NREL_WTK/WTK_NYfull/',zone,'/',wtk_yr,sep=''), skip=1)
        #wtk$era <- era$x
        
        stability_coeff <- (log(wtk$wind.speed.at.100m..m.s.) - log(merra$x))/(log(100)-log(10))
        wtk$pcoef <- stability_coeff
        
        df <- wtk[wtk$Month == i,]
        
        yr_pcoef<- aggregate(df$pcoef, by = list(df$Hour), FUN = mean)
        
        avgmonth_pcoef <- cbind(avgmonth_pcoef,yr_pcoef$x)
      }
      
      temp<-rep(rowMeans(avgmonth_pcoef),mthdays[i])
      coef_full_yr <- c(coef_full_yr,temp)
      write.csv(rowMeans(avgmonth_pcoef),paste("Data/RenewableGen/Wind/NREL_WTK/StabilityCoef/YearlyCoef_LZ/",zone,"/coef_",siteid,"_",lat,'_',lon,'_',mths[i],'.csv',sep = ''))
      
    }
    dat<-data.frame(coef_full_yr)
    colnames(dat) <- c('stabilitycoef')
    write.csv(dat,paste("Data/RenewableGen/Wind/NREL_WTK/StabilityCoef/YearlyCoef_LZ/",zone,"/coef_",lat,'_',lon,'.csv',sep = ''))
  }
}
