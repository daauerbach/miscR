## Access and repackage NHDPlus EROM
## Generates per-VPU data.frames with annual and monthly mean flow estimates
## associated with the flowlines in the hydrography snapshot
## See: ftp://ftp.horizon-systems.com/NHDPlus/NHDPlusV21/Documentation/TechnicalDocs/EROM_Monthly_Flows.pdf
library(dplyr)

fcodes <- readRDS(gzcon(url("https://github.com/daauerbach/miscR/raw/master/table_NHDFCodes.rds"))) %>%
  select(FCode,Hydrograph,Descriptio)


dirzip <- "your directory path"
setwd(dirzip)
#Mid-Atlantic already done
#Ark/Red
uz <- "ftp://www.horizon-systems.com/NHDPlus/NHDPlusV21/Data/NHDPlusMS/NHDPlus11/NHDPlusV21_MS_11_EROMExtension_03.7z"
#Lower Colo
uz<-"ftp://www.horizon-systems.com/NHDPlus/NHDPlusV21/Data/NHDPlusCO/NHDPlus15/NHDPlusV21_CO_15_EROMExtension_06.7z"
uz<-"ftp://www.horizon-systems.com/NHDPlus/NHDPlusV21/Data/NHDPlusCO/NHDPlus15/NHDPlusV21_CO_15_NHDSnapshot_04.7z"
#PNW
uz<-"ftp://www.horizon-systems.com/NHDPlus/NHDPlusV21/Data/NHDPlusPN/NHDPlusV21_PN_17_EROMExtension_08.7z"
uz<-"ftp://www.horizon-systems.com/NHDPlus/NHDPlusV21/Data/NHDPlusPN/NHDPlusV21_PN_17_NHDSnapshot_08.7z"
if(!file.exists(basename(uz))){
  download.file(uz, destfile=basename(uz), quiet = F, mode=ifelse(Sys.info()["sysname"]=="Windows","wb","w"))
}
#7unzip manually (can be done via system call on a machine with 7zip or similar in path)

#Join the EROM flow info, see overall and Seamless user guides
#Want "QE_*" as "best EROM estimate of actual flow" (versus natural in QC)
#quick/dumb little helper expecting to be run in directory with files
bindEROM <- function(vpu){
  ma <- foreign::read.dbf("EROM_MA0001.DBF")%>%
    select(ComID, AreaSqKm, Q0001E, Qincr0001E, Temp0001:QLoss0001)
  names(ma)[3:8]<-paste0("MA_",names(ma)[3:8])
  lapply(list.files(pattern = "EROM_")[-13]
         ,function(fn){
           d <- foreign::read.dbf(fn)%>%select(ComID, Q0001E)
           names(d)[2] = paste0(substr(fn,6,7),"_",names(d)[2])
           return(d)
         }) %>%
    Reduce(function(d1,d2) left_join(d1,d2,by="ComID"), .) %>%
    left_join(ma, .,by="ComID") %>%
    rename(COMID = ComID) %>% 
    mutate(vpu = vpu) -> z
  return(z)
}


#If maintaining original NHDPlus directory naming conventions, 
#bit of a PIA to loop with a wrapper due to minor feature name inconsistency
#Next steps warrant exploring an export of the seamless
##Mind that EROM not avail for all features in geometry snapshots

setwd("/Users/dauerbac/Documents/R/NHDPlusMA/NHDPlus02/EROMExtension")
vpu02 <- bindEROM("vpu02")
foreign::read.dbf("/Users/dauerbac/Documents/R/NHDPlusMA/NHDPlus02/NHDSnapshot/Hydrography/NHDFlowline.dbf", as.is = T) %>%
  left_join(fcodes, by=c("FCODE"="FCode")) %>%
  right_join(vpu02, by="COMID") -> vpu02

setwd("/Users/dauerbac/Documents/R/NHDPlusMS/NHDPlus11/EROMExtension")
vpu11 <- bindEROM("vpu11")
foreign::read.dbf("/Users/dauerbac/Documents/R/NHDPlusMS/NHDPlus11/NHDSnapshot/Hydrography/NHDFlowline.dbf", as.is = T) %>%
  left_join(fcodes, by=c("FCODE"="FCode")) %>%
  right_join(vpu11, by="COMID") -> vpu11

setwd("/Users/dauerbac/Documents/R/NHDPlusCO/NHDPlus15/EROMExtension")
vpu15 <- bindEROM("vpu15")
foreign::read.dbf("/Users/dauerbac/Documents/R/NHDPlusCO/NHDPlus15/NHDSnapshot/Hydrography/NHDFlowline.dbf", as.is = T) %>%
  left_join(fcodes, by=c("FCode"="FCode")) %>%
  right_join(vpu15, by=c("ComID"="COMID")) -> vpu15

setwd("/Users/dauerbac/Documents/R/NHDPlusPN/NHDPlus17/EROMExtension")
vpu17 <- bindEROM("vpu17")
foreign::read.dbf("/Users/dauerbac/Documents/R/NHDPlusPN/NHDPlus17/NHDSnapshot/Hydrography/NHDFlowline.dbf", as.is = T) %>%
  left_join(fcodes, by=c("FCODE"="FCode")) %>%
  right_join(vpu17, by=c("COMID"="COMID")) -> vpu17

setwd("path/to/local/miscR/dataEROM")
saveRDS(vpu02,"erom_vpu02.rds")
saveRDS(vpu11,"erom_vpu11.rds")
saveRDS(vpu15,"erom_vpu15.rds")
saveRDS(vpu17,"erom_vpu17.rds")

