# miscR
odd and ends

## Description

**_CAVEAT EMPTOR!_**
This repo contains in-progress scripts depending on an updated base R installation as well as various packages. Some effort has been made to ensure that dependencies are installed and loaded, but this is firmly "research grade" scripting 

Functions can be individually source()'d in a session via [devtools::source_url](http://www.inside-r.org/packages/cran/devtools/docs/source_url), for example: (note "raw" url)
```R
devtools::source_url("https://raw.githubusercontent.com/daauerbach/miscR/master/func_calcLndscpFtrWtlndThematicExtract.R")
```


## Functions
 
 + **func_calcLndscpFtrWtlndThematicExtract** is a parallelized raster extract function for CONUS landscape features related to wetlands, currently  [PWA](https://enviroatlas.epa.gov/enviroatlas/DataFactSheets/pdf/supplemental/potentialwetlandarea.pdf), [NEF, link is to webservice not full data ](https://www.sciencebase.gov/arcgis/rest/services/Catalog/5363b779e4b08180b014255c/MapServer/) and [NLCD2011](https://www.mrlc.gov/nlcd2011.php). It is **not** very generalized but should be easy to modify. Presuming the raster datasets are available (not checked) at the paths in function args, it takes a `SpatialPolygonsDataFrame` object and returns a dataframe of percentages and raw areas for each value/level of the rasters in each polygon.
 
## Objects

 + **dataSpatial** contains a number of `SpatialPolygonDataFrame.rds`: states, EPA regions, Army Corps regulatory districts, and CONUS Level3 ecoregions
 
