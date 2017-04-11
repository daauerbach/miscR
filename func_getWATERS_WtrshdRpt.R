## Very simple function to return NHDPlus "watershed report"
## https://www.epa.gov/waterdata/watershed-characterization-service
## Not utilizing all options
## Will need updating when new report is in production

getWATERS_WtrshdRpt <- function(
  comid = "4795168" #also can accept pPermanentIdentifier, pFeatureID
  #can get html returned, but fixing optOutFormat = "JSON"
  #skipping optOutPrettyPrint since only interested in parsing at this point
  #can also get geom back in EPSG:4269 if optOutGeomFormat=GEOJSON, also option to project via optOutCS
  ,u = "https://ofmpub.epa.gov/waters10/Watershed_Characterization.Control" #base service endpoint
){
  library(dplyr)
  #build the query url
  uq <- paste0(u, paste0("?pComID=",comid,"&optOutFormat=JSON"))
  #make the query
    #could/should?? add better checks for $status$status_code != 0
    #currently just silently fails as NULL (ok for now)
  #Underlying jsonlite does not like negative decimal values with no preceding integer
  #" Error: lexical error: malformed number, a digit is required after the minus sign."
  #Not fully fixing for the moment, given pending rewrite around new service format
  j <- try(httr::content(httr::GET(uq), type="application/json"))
  if(is.list(j)) {
    s <- j$output #should be 61 element list
  } else { s <- NULL }
  return(s)
}


#httr::GET(uq)%>%httr::content(type="application/json")%>%  .$output -> s