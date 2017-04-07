## Very simple function to return NHDPlus "watershed report"
## https://www.epa.gov/waterdata/watershed-characterization-service
## Not utilizing all options
## Will need updating when new report is in production

getWATERS_WtrshdRpt <= function(
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
  httr::GET(uq)%>%
    httr::content(type="application/json") %>% #2element list
    .$output -> s
  #61 element named list if !NULL
  return(s)
}