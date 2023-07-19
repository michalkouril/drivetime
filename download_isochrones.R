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

# read in geocoded facilities data
# centers <- read_csv("center_addresses.csv") %>% 
centers <- read_csv("ctsa_centers.csv") %>% 
  arrange(abbreviation)

isochrones <- readRDS("isochrones/isochrones.rds")

# download isochrones from ORS
get_isochrones <- function(x) {
  if (length(isochrones) >= x && length(isochrones[[x]]) > 1) {
    isochrones[[x]]
  } else {
  ors_isochrones(as.numeric(centers[x, c('lon', 'lat')]),
                 profile = 'driving-car',
                 range = 60*60,   
                 interval = 6*60,
                 output = "sf") %>%
    st_transform(5072)
  }
}

# ex <- get_isochrones(1)
# ggplot() + 
#   geom_sf(data = ex[2,]) +
#   geom_sf(data = ex[1,]) 

isochrones <- mappp::mappp(1:nrow(centers), get_isochrones)

saveRDS(isochrones, 'isochrones/isochrones.rds')
# isochrones <- readRDS('drivetime_distance/cf_isochrones.rds')

removeOverlap <- function(x) {
  x <- x %>%
    mutate(drive_time = as.factor(value/60)) %>%
    select(drive_time, geometry)
  p <- list()
  p[[1]] <- x[1,]
  for(i in 2:nrow(x)) {
    p[[i]] <- st_difference(x[i,], x[i-1,]) %>%
      select(drive_time, geometry)
  }
  do.call(rbind, p)
}

l <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65)
# ok l <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,36,37,38,39,40,41,42,43,44,45)
# ok l <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34)
# ok l <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)
# l <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35)
# l <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40)
# l <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30)

isochrones <- isochrones[l]
centers <- centers[l,]

isochrones_no_overlap <- map(isochrones, removeOverlap)
names(isochrones_no_overlap) <- centers$abbreviation
saveRDS(isochrones_no_overlap, 'isochrones_no_overlap.rds')

purrr::walk(1:length(isochrones_no_overlap),
           ~saveRDS(isochrones_no_overlap[[.x]], 
                    glue::glue('isochrones/{names(isochrones_no_overlap)[.x]}_isochrones.rds')))


