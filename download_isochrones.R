# options(openrouteservice.url = "http://10.0.1.139:8088/ors")
# options(openrouteservice.paths = list(directions = "v2/directions",
#                                       isochrones = "v2/isochrones",
#                                       matrix = "v2/matrix",
#                                       geocode = "geocode",
#                                       pois = "pois",
#                                       elevation = "elevation",
#                                       optimization = "optimization"))

library(tidyverse)
library(sf)
library(openrouteservice) # remotes::install_github("GIScience/openrouteservice-r")

options(openrouteservice.url = "http://10.200.42.250:8088/ors")

iso_filename <- Sys.getenv("ISO_FILENAME", "./isochrones.rds")
centers_filename <- Sys.getenv("CENTERS_FILENAME", "./ctsa_centers.csv")
cache_name <- Sys.getenv("CACHE_NAME", "cache")

# read in geocoded facilities data
# centers <- read_csv("center_addresses.csv") %>% 
centers <- read_csv(centers_filename) %>% 
  arrange(abbreviation)

if (file.exists(iso_filename))  {
   isochrones <- readRDS(iso_filename)
} else {
   isochrones <- data.frame()
}

# isochrone ranges
# ranges <- c(seq(0.25,4,0.25),seq(5,8,1),seq(10,16,2))
# ranges <- c(seq(0.25,4,0.25),seq(5,8,1)); smoothing <- 0.5
ranges <- c(seq(10,16,2)); smoothing <- 0.5
# ranges <- c(seq(5,8,1)); smoothing <- 0.5
# ranges <- c(seq(0.25,4,0.25)); smoothing <- 0.5

# convert hours to seconds
ranges <- 3600*ranges

# download isochrones from ORS
get_isochrones <- function(x) {
  if (length(isochrones) >= x && length(isochrones[[x]]) > 1) {
    isochrones[[x]]
  } else {
  ors_isochrones(as.numeric(centers[x, c('lon', 'lat')]),
                 profile = 'driving-car',
                 range = ranges,
		 smoothing = smoothing,
                 # range = 60*60*1,   
                 # interval = 15*60,
                 output = "sf") %>%
    st_transform(5072)
  }
}

isochrones <- mappp::mappp(1:nrow(centers), get_isochrones, error_quiet = FALSE, cache = TRUE, cache_name = cache_name) # , parallel = TRUE, num_cores = 8)
# isochrones <- mappp::mappp(1:1, get_isochrones, error_quiet = FALSE, cache = TRUE, cache_name = cache_name)
# , parallel = TRUE, num_cores = 4)

saveRDS(isochrones, iso_filename)
