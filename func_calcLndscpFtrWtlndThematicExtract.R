## Dan Auerbach, spring 2017

## --------------------------------------
#### Wetlands-related Thematic extract function
## --------------------------------------
##Extract multigeom spdf against PWA (TWI+PWSL), NLCD2011, and NEF, then convert the per-polygon matrices of pixel values to percentages by class
##see original IRTscreen script (e.g., flipped "*.vals" to "*.lvls"; elements of those direct from native attrib tables; etc.)
##cropping gives minor speedup for single poly geom, but parallelized faster for multirow spdf via beginCluster/endCluster
##note differences in missing data between rasters can mean that summed areas (across classes) are not necessarily identical for a given bank poly
##Elected to focus on PWA due to a) consistency with TWI & PWSL separately b) conceptual simplicity and c) already have CONUS@30m, whereas PWSL only R4@10m
calcLndscpFtr = function(
  spdf #target polys (could modify to points)
  ,pwa = raster("dataRaster/PWA/PWA.tif")
  ,pwa.lvls = setNames(as.character(0:3), c("no","lo","md","hi"))
  ,nef = raster("dataRaster/National Ecological Framework/nef3_0b.tif")
  ,nef.lvls = setNames(as.character(0:3), c("bckg","hubs","crrd","auxC"))
  ,nlcd = raster("../NHDplus/NLCD2011/nlcd_2011_landcover_2011_edition_2014_10_10.img")
  ,nlcd.lvls = setNames(as.character(c(0,11,12,21,22,23,24,31,41,42,43,52,71,81,82,90,95)), c("Unclassified","OpenWater","PerennialSnowIce","Developed,OpenSpace","Developed,LowIntensity","Developed,MediumIntensity","Developed,HighIntensity","BarrenLand","DeciduousForest","EvergreenForest","MixedForest","ShrubScrub","Herbaceuous","HayPasture","CultivatedCrops","WoodyWetlands","EmergentHerbaceuousWetlands"))
  ,nc = 4 #cores
  ,dirRun = "/Users/dauerbac/Google Drive/404MitigationScreen"
  ,dirOut = "dataRobjects" #subdirectory (not currently smart about checking/creating)
){
  on.exit(setwd(getwd()))
  setwd(dirRun)
  ####internal helper takes target raster, focal spdf, known as.character(raster values), and the name strings associated with those vals
  ##converts list of 2-col matrices of pixel vals (value/r & weight) into tall matrix rows-per-poly, cols-per-values (named)
  ##percentages via summed pixels/weights by factor/thematic level
  ##absAreas via product of percentage, ncells in poly and cell resolution (note potentially diff from gArea on poly * pcts)
  rextr = function(r, p, lvl, lbl){
    rx = raster::extract(r, spTransform(p, r@crs), weights=T, normalizeWeights=T) #generates list of 2col matrices (colnames="r"&"weight", not parallel "value"&"weight")
    sapply(rx, function(m) {
      pct = tapply(m[,2], factor(m[,1], levels = lvl, labels = paste0("pct_",lbl)), sum, na.rm=T)
      pct = round(pct, 3)
      pct[is.na(pct)] = 0 #the tapply only returns NA when all NA for a value/level
      c(pct, setNames(round((pct * nrow(m) * prod(res(r))/1e+6),3), paste0("sqkm_",lbl)))
    }) -> z
    return(t(z))
  }
  #now execute that against the 3 focal rasters
  library(parallel)
  beginCluster(nc)
  m1 = rextr(pwa, spdf, lvl = pwa.lvls, lbl = names(pwa.lvls))
  m2 = rextr(nef, spdf, lvl = nef.lvls, lbl = names(nef.lvls))
  m3 = rextr(nlcd, spdf, lvl = nlcd.lvls, lbl = names(nlcd.lvls))
  endCluster()
  
  m = cbind(m1,m2,m3)
  saveRDS(m, paste0(dirOut,"/", deparse(substitute(spdf)) ,"_LndscpFtr.rds"))
  return(m)
} #end calcLndscpFtr

