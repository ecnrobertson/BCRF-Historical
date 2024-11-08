library(dplyr)
library(ggplot2)
library(ggnewscale)
library(data.table)
library(raster)
library(terra)
library(Rnaturalearth)

DMNS <- read.csv("sample_data/BCRF_DMNS_samples.csv")
DMNS$MUSEUM <- "DMNS"
CRCM <- read.csv("sample_data/BCRF_CRCM_samples.csv")
CRCM$MUSEUM <- "CRCM"
MVZ <- read.csv("sample_data/BCRF_MVZ_samples.csv")
MVZ$MUSEUM <- "MVZ"
UCM <- read.csv("sample_data/BCRF_UCM_samples.csv")
UCM$MUSEUM <- "UCM"
UMMZ <- read.csv("sample_data/BCRF_UMMZ_samples.csv")
UMMZ$MUSEUM <- "UMMZ"

#The UMMZ csv isn't exactly the same as the others, so I'm changing the column names to match and
#then adding the same format for the GUID column
colnames(UMMZ) <- colnames(DMNS)
UMMZ$GUID <- paste("UMMZ:Bird", UMMZ$GUID, sep = ":")

all_samples <- as.data.table(rbind(DMNS,CRCM,MVZ,UCM,UMMZ))

samples.locals <- all_samples[,.(MUSEUM,GUID,DEC_LAT,DEC_LONG)]

#Putting together high resolution elevation data for the BCRF working area
#Downloading .tifs off of USGS website and merging them together
file_list <- list.files(path="/Users/ericarobertson/Desktop/BCRF/BCRF-Historical/mapping_data/USGS_TIFF/", pattern="*.tif", all.files=TRUE, full.names=TRUE)
test_raster <- raster("/Users/ericarobertson/Desktop/BCRF/BCRF-Historical/mapping_data/USGS_TIFF/USGS_13_n36w105_20220801.tif")
allrasters <- lapply(file_list, rast)
allrasters <- aggregate(allrasters, 10)


#merging the files together into a single elevation raster for Colorado
merged <- do.call(aggregate(mean), allrasters)
writeRaster(merged, "/Users/ericarobertson/Desktop/BCRF/BCRF-Historical/mapping_data/raw_BCRF_working_area_elev.tif")
merged.ag <- aggregate(merged, 10)

#reprojecting the elevation and pulling out slope values
elev <- terra::project(merged, y="+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

writeRaster(elev,"BCRF_working_area_elev.tif", overwrite=TRUE)


ggplot(data=samples.locals, aes(x=))+
  geom_point()

