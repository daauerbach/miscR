## Generate a mapview template with common WMS layers
## Including EPA region bounds
## Very alpha

makeMVbase <- function(
  spobj = NULL
  ,zcol = NULL, burst=F, legend=T, leg.op=0.5, pal=rainbow(6), mt=2:4
  ,EPA=T  
  ,wms = c("NHD","NHD+cat", "NLCD", "TWI")
  #,GSWrecur=T
  ){
  library(sp)
  library(rgdal)
  library(dplyr)
  library(mapview)

  epa <- readRDS(gzcon(url("https://github.com/daauerbach/miscR/raw/master/dataSpatial/spdf_epareg.rds")))
  epa@data <- epa@data %>% select(-r.int) %>% rename(Region = r.char)
  mepa <- mapview::mapview(epa, zcol="Region"
                           ,legend=T, legend.opacity=0.5
                           ,color=terrain.colors(6)
                           ,map.types=mapviewGetOption("basemaps")[mt]
                           )
  
  if(is.null(spobj)) {
    m <- mepa 
    } else {
      if( !grepl("sp", attr(class(spobj),"package")) ) { #|raster
        print("Object does not appear to be a sp class")
        return(NULL)
        } else {
          m <- mapview::mapview(
            spobj, layer.name = deparse(substitute(spobj))
            ,zcol=zcol, burst=burst
            ,legend=legend, legend.opacity=leg.op
            ,color=pal
            ,map.types=mapviewGetOption("basemaps")[mt]
            )
          #add the EPA region polys as a layer?
          if(EPA){ m <- m + mepa }
          } #end SpatialClass
      } #end passed spobj

  if("NHD" %in% wms) {
    m@map <- m@map %>%
      addWMSTiles(group="NHD", baseUrl="https://basemap.nationalmap.gov/arcgis/services/USGSHydroCached/MapServer/WMSServer?"
                  ,layers = "0", options = WMSTileOptions(format = "image/png", transparent = TRUE), attribution = "USGS")
  }
  if("NHD+cat" %in% wms) {
    m@map <- m@map %>%
      addWMSTiles(group="NHD+cat", baseUrl="https://watersgeo.epa.gov/arcgis/services/NHDPlus_NP21/Catchments_NP21_Simplified/MapServer/WMSServer?"
                  ,layers = "0", options = WMSTileOptions(format = "image/png", transparent = TRUE), attribution = "EPA")
  }
  if("NLCD" %in% wms) {
    m@map <- m@map %>%
      addWMSTiles(group="NLCD", baseUrl="http://isse.cr.usgs.gov/arcgis/services/LandCover/USGS_EROS_LandCover_NLCD/MapServer/WMSServer?"
                  ,layers = c("1","6"), options = WMSTileOptions(format = "image/png", transparent = TRUE), attribution = "USGS")
  }
  if("TWI" %in% wms) {
    m@map <- m@map %>%
     addWMSTiles(group="TWI", baseUrl="https://geoplatform1.epa.gov/arcgis/services/NEF/WetnessIndex/MapServer/WMSServer?"
                 ,layers = "0", options = WMSTileOptions(format = "image/png", transparent = TRUE), attribution = "EPA")
  }

  m@map <- m@map %>% mapview:::mapViewLayersControl(names = wms)
  
  #hack to ensure things can be seen
  for(i in which(sapply(m@map$x$calls,function(i) i$method)=="addWMSTiles")) {
    m@map$x$calls[[i]]$args[[4]]$zIndex = i
  }    
  
  # #"worked", but repeatedly crashing
  # if(GSWrecur) {
  #   m@map <- m@map %>%
  #     addTiles(group="GSWrecur"
  #              ,urlTemplate = "https://storage.googleapis.com/global-surface-water/maptiles/recurrence/{z}/{x}/{y}.png"
  #              ,options = tileOptions(
  #                noWrap=T, format = "image/png", maxNativeZoom = 13
  #                ,errorTileUrl = "https://storage.googleapis.com/global-surface-water/downloads_ancillary/blank.png")
  #              ,attribution = "EC JRC/Google")
  #   m@map <- leaflet::addLayersControl(map = m@map, position = mapviewGetOption("layers.control.pos")
  #                                  ,baseGroups = c(m@map$x$calls[[mapview:::getLayerControlEntriesFromMap(m@map)[1]]]$args[[1]]
  #                                                  ,"GSW recurr")
  #                                  ,overlayGroups = mapview:::getLayerNamesFromMap(m@map))
  # }
  
  return(m)
}

#makeMVbase()

# # too big for lightweight standalone html
# ace <- readRDS(gzcon(url("https://github.com/daauerbach/miscR/raw/master/dataSpatial/spdf_ACEregDist.rds")))
# aceSmp <- readRDS(gzcon(url("https://github.com/daauerbach/miscR/raw/master/dataSpatial/spdf_ACEregCONUS_Simp.rds")))
# usL3Smp <- readRDS(gzcon(url("https://github.com/daauerbach/miscR/raw/master/dataSpatial/spdf_conusL3ecoregUnionSimplpolys.rds")))
# #small enough but derived epa smaller
# conus <- readRDS(gzcon(url("https://github.com/daauerbach/miscR/raw/master/dataSpatial/spdf_conus.rds")))
