## Function to query EPA WATERS Point indexing service
## https://www.epa.gov/waterdata/point-indexing-service
##  generates a url string, hits the endpoint and
##  returns a list of results if possible
##NOT YET HEAVILY TESTED

#NAD83 point 
#Method "Nearest" is pretty self-explanatory
#Raindrop, see various caveats: https://www.epa.gov/waterdata/raindrop-tool
#Suggested best practices:
# use maxRainDrop 10km outside SW
# use maxSnap 2km
# consider excluding FCODES, esp pipelines

getWATERS_PtSvc <- function(
  lon = -76.93004256521864
  ,lat = 38.957019467088394
  ,pPointIndexingMethod = "RAINDROP" #or DISTANCE
  ,pPointIndexingMaxDist = 2 #snap distance, service default is 2km
  ,pPointIndexingRaindropDist = 10 #max raindrop traversal (then +max snap), default is 5km

  #,pPointIndexingFcodeAllow = c(46003,46006,46007, 55800,56700) #Int,Per,Eph; ArtPath
  #,pPointIndexingFcodeDeny
  #Unused, docs all indicate NAD83/WGS84 as defaults: ,pGeometryMod = "WKT,SRSNAME=urn:ogc:def:crs:OGC::CRS84"
  #,optOutPrettyPrint = 0
  ,u = "http://ofmpub.epa.gov/waters10/PointIndexing.Service" #base service endpoint
){
  library(dplyr)
  #build the query url
  pG = paste0("POINT(",lon,"%20",lat,")") #the NAD83 point to query
  uq <- paste0(u
               ,paste0("?pGeometry=",pG)  #collapse = "%7C"
               ,paste0("&pPointIndexingMethod=",pPointIndexingMethod)
               ,paste0("&pPointIndexingMaxDist=",pPointIndexingMaxDist)
               ,paste0("&pPointIndexingRaindropDist=",pPointIndexingRaindropDist)
               ,"&optOutFormat=JSON"
  )
  #make the query
  j <- try(httr::content(httr::GET(uq), type="application/json"))
  if(is.list(j)) {
    s <- j$output
  } else { s <- NULL }
  return(s)
}