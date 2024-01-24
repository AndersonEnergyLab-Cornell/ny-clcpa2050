wind_to_power <- function(wind,pcurve) {
  #Power Curve 1-3 are IEC Curve 1-3
  #Power Curve 4 is for Offshore
  pcurves<-read.csv("Data/RenewableGen/Wind/PowerCurves.csv")
  power<-pcurves[,pcurve+1]
  spd <- pcurves[,1]
  n <- length(wind)
  wpower <- rep(0, n)
  for (i in 1:length(wind)){
    mindist <- min(abs(spd - wind[i]))
    sgndist <- spd - wind[i]
    ndx <- which(mindist == abs(spd - wind[i]))[1]
    #print(sgndist[ndx])
    if (sgndist[ndx] == 0) {
      wpower[i] <- curve[ndx]
      #print("damn")
    }
    else if (wind[i] > max(spd)) {
      wpower[i] <- 0
      sgndist <- 0
    }
    else if (sgndist[ndx] < 0){
      numerator <- power[ndx+1] - power[ndx]
      denominator <- spd[ndx+1] - spd[ndx]
      wpower[i] <- numerator/denominator * (wind[i] - spd[ndx]) + power[ndx]
      #print("fck")
    }
    else {
      numerator <- power[ndx] - power[ndx-1]
      denominator <- spd[ndx] - spd[ndx-1]
      wpower[i] <- numerator/denominator * (wind[i] - spd[ndx-1]) + power[ndx-1]
      
    }
  }
  return(wpower)
}