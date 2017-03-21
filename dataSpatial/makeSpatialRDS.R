library(sp) 
library(rgdal)
library(rgeos)
library(dplyr)


## --------------------------------------
#### #states from TIGER
## --------------------------------------
setwd("dataSpatial")
tmp_dl <- tempfile()
download.file("http://www2.census.gov/geo/tiger/GENZ2013/cb_2013_us_state_20m.zip", tmp_dl)
unzip(tmp_dl, exdir=tempdir())
ST <- readOGR(tempdir(), "cb_2013_us_state_20m", stringsAsFactors = F)
ST@data = ST@data[,c(5,6,8,9)]
row.names(ST)=ST$STUSPS
x=setNames(c(4,10,9,6,9,8,1,3,4,4,9,10,5,5,7,7,4,6,1,3,1,5,5,4,7,8,7,9,1,2,6,2,4,8,5,6,10,3,1,4,8,4,6,8,1,3,10,3,5,8), state.abb)
x["DC"]=3; x["PR"]=2
ST$EPAregion=x[ST$STUSPS]
ST$EPAregCol = c(topo.colors(9), "chocolate4")[ST$EPAregion]
ST = spTransform(ST, CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"))
saveRDS(ST, "spdf_States52.rds")

#drop AK, HI & PR
ST[!grepl("AK|HI|PR",ST$STUSPS),] %>%
  saveRDS(., "spdf_conus.rds")
## --------------------------------------


## --------------------------------------
#### CONUS Level3 ecoregions, raw/full and union+simplify
## --------------------------------------
##ftp://newftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l3.zip
# unzip("/Users/dauerbac/Downloads/us_eco_l3.zip", exdir = "/Users/dauerbac/Google Drive/NHDplus/ecoregions")
# x = readOGR("/Users/dauerbac/Google Drive/NHDplus/ecoregions","us_eco_l3", stringsAsFactors = F) #1250x13
# gIsValid(x) #False
# x = gBuffer(x, byid=TRUE, width=0) 
# gIsValid(x) #True
# saveRDS(x,"/Users/dauerbac/Google Drive/NHDplus/ecoregions/ecoregL3conus.rds")

us = readOGR(dsn = "/Users/dauerbac/Google Drive/NHDplus/ecoregions", layer = "us_eco_l3", stringsAsFactors = F) #43.8mb
length(unique(us$US_L3NAME)) #85 Level3s; alluvial & coastal plains have the greatest separate polygons: sort(table(us$US_L3NAME),decreasing = T)
gIsValid(us) #False, these include a self-intersection that will break things
us = gBuffer(us, byid=TRUE, width=0) #fix that first; now true: gIsValid(us)
#This merge/dissolve/union generates a spatial object without attributes
#but each polygon @ID corresponds to a level of the field defining the union  
us.webpolys = rgeos::gUnaryUnion(us, id = us$US_L3NAME) #85 polys, 42mb; see: sapply(us.webpolys@polygons, function(p) p@ID)
#Now spatially simplify (reduce number of coordinates)
us.webpolys = rgeos::gSimplify(us.webpolys, tol=70, topologyPreserve = T) #now 8.8mb
#worthwhile checks: gIsValid(us.webpolys); plot(us); plot(us.webpolys, add=T, border="lightblue")
#Adding back attributes can get tricky if they vary within the merge field
#Here simply taking the remaining field vals of the first row of each distinct L3NAME 
us.webdata = us@data %>% dplyr::distinct(US_L3NAME, .keep_all = T) %>% dplyr::select(US_L3NAME,US_L3CODE,L2_KEY,L1_KEY)
us.web = SpatialPolygonsDataFrame(Sr = us.webpolys, data = us.webdata, match.ID = "US_L3NAME")
saveRDS(us.web, paste0("spdf_conusL3ecoregUnionSimplpolys.rds"))
## --------------------------------------







#CorpsMap regulatory district spatial polygons
# unzip("ACEregDistrictBoundary.zip", exdir=tempdir())
# ace = spTransform(readOGR(tempdir(), "regulatoryboundary2015", stringsAsFactors = F), crs(conus))
# ace$dis = toupper(sapply(strsplit(ace$WEB_ADDR,":"), function(x) substr(x[2],7,9)))
# ace$div = substr(ace$dis,1,2)
# row.names(ace)=ace$dis
# ace = ace[sort(row.names(ace)),]
# saveRDS(ace, "spdf_ACEregDist.rds")
ace = readRDS("spdf_ACEregDist.rds")
colacediv = setNames(rainbow(8)[as.numeric(factor(unique(ace$div)))], unique(ace$div))
ace = ace[-grep("POA|POH",ace$dis),] #drop AK & HI for consistency

