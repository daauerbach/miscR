##Simple function to query EPA WATERS RAD event webservice
## https://www.epa.gov/waterdata/rad-event-info-service
##  generates a url string, hits the endpoint and
##  returns a list of results if the source_featureid is valid
##NOT YET HEAVILY TESTED

#pRadQuery defines the query consisting of a string of rad_program (e.g., NPDES), source_featureid and T/F archive flag
#   these elements are separated by '%7C' in url (replacing js |)
#pRadQueryMod modifies the query string according to "complex object modifier" rules: https://www.epa.gov/waterdata/waters-http-services
#   '%2C' is just an encoded comma: http://stackoverflow.com/questions/6182356/what-is-2c-in-a-url
#pRADUsageModel needs to be pt1to1
#deconstructed template URL from code examples:
#https://ofmpub.epa.gov/waters10/RadEventInfo.Service?pRadQuery=NPDES%7CNE0113735%7CFALSE&pRadQueryMod=%7C%2C&pRADUsageModel=pt1to1&f=json

getWATERS_RADevent <- function(
  i = "NE0113735" #the primary source_featureid to query
  ,radp = "NPDES" #the RAD program of interest
  ,arch = "FALSE" #include archive results
  ,u = "http://ofmpub.epa.gov/waters10/RADEventInfo.Service" #base service endpoint
){
  #build the query url
  uq <- paste0(u
               ,paste0("?pRadQuery=",paste0(c(radp,i,arch),collapse = "%7C"))
               ,"&pRadQueryMod=%7C%2C&pRADUsageModel=pt1to1&f=json"
  )
  #make the query
  #could/should?? add better checks for $status$status_code != 0
  #currently just silently fails as NULL (ok for now)
  httr::GET(uq)%>%
    httr::content(type="application/json") %>% #2element list
    .$output %>% .$results %>%
    .[[1]] -> s
  return(s)
} #end getWATERS_RADevent
