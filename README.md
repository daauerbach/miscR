# miscR
odd and ends

## Description

**_CAVEAT EMPTOR!_**
This repo contains in-progress scripts and objects depending on an updated base R installation as well as various packages. Some effort has been made to ensure that dependencies are installed and loaded, but this is firmly "research grade" scripting 

Functions can be individually source()'d in a session via [devtools::source_url](http://www.inside-r.org/packages/cran/devtools/docs/source_url), for example:
```R
devtools::source_url("https://raw.githubusercontent.com/daauerbach/miscR/master/func_calcLndscpFtrWtlndThematicExtract.R")
```
Likewise, data objects:
```R
conus <- readRDS(gzcon(url("https://github.com/daauerbach/miscR/raw/master/dataSpatial/spdf_conus.rds")))
```

## Scripts

 + **2017MarEPAwebinar** includes the markdown and html illustrating a basic web mapping workflow, including local objects and geospatial web services and deploying `leaflet` via the excellent `mapview` package.
 
 + **catRank** includes the markdown and html illustrating a simple catchment prioritization exercise on NHDPlus, incorporating StreamCat landscape attributes and EROM flow estimates for King Country, WA.

## Functions
 
 + **func_calcLndscpFtrWtlndThematicExtract** is a parallelized raster extract function for CONUS landscape features related to wetlands, currently  [PWA](https://enviroatlas.epa.gov/enviroatlas/DataFactSheets/pdf/supplemental/potentialwetlandarea.pdf), [NEF, link is to webservice not full data ](https://www.sciencebase.gov/arcgis/rest/services/Catalog/5363b779e4b08180b014255c/MapServer/) and [NLCD2011](https://www.mrlc.gov/nlcd2011.php). It is **not** very generalized but should be easy to modify. Presuming the raster datasets are available (not checked) at the paths in function args, it takes a `SpatialPolygonsDataFrame` object and returns a dataframe of percentages and raw areas for each value/level of the rasters in each polygon.
 
**VERY ALPHA Functions**

 + **func_makeMVbase** generates a base mapview with several key WMS services that is suited to additional spatial data layers via `+`. Commented out the "GSWrecur[rence]" base group tiles after repeated Rstudio crashes (though this is looking like it may be a mapview/Rstudio bug)
 
 + **func_getWATERS_RADevent** Simple function to query EPA WATERS [RAD event webservice](https://www.epa.gov/waterdata/rad-event-info-service). Generates a url string, hits the endpoint and returns a list of results if the source_featureid is valid.

 + **func_getWATERS_WtrshdRpt** Simple function to query EPA WATERS [Watershed Characterization](https://www.epa.gov/waterdata/watershed-characterization-service). Fixed on COMID input and JSON output. Will need updating shortly pending ongoing updates in service.
 
 + **func_getWATERS_PtSvc** Simple function to query EPA WATERS [Point Indexing Service](https://www.epa.gov/waterdata/point-indexing-service). Given a long-lat, will attempt to return the nearest NHD element (by the default "Raindrop" method, following the NHDPlus flow direction grid). Cool!
 
## Objects

 + **dataSpatial** contains a number of `SpatialPolygonDataFrame.rds`: states, EPA regions, Army Corps regulatory districts, and CONUS Level3 ecoregions
 
 + **dataEROM** contains per-VPU `data.frames` of NHDPlus [EROM](ftp://ftp.horizon-systems.com/NHDPlus/NHDPlusV21/Documentation/TechnicalDocs/EROM_Monthly_Flows.pdf) streamflow estimates (MAF and monthly mean, all cfs) associated with the flowlines in the corresponding hydrography snapshot.

 + **table_NHDFCodes** is a lookup of NHD FCodes to descriptions and key attributes, especially "Hydrograph"
