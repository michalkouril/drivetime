library(tidyverse)
library(sf)
library(dplyr)

iso0_4_15<-readRDS("isochrones_4hr_15min_smoothering0.5.rds")
iso5_8_1<-readRDS("isochrones_CHECKME_TOO.rds")
iso10_16_2<-readRDS("isochrones_10-16hrs_by2hrs_smooting=0.5.rds")

centers_filename <- "../ctsa_centers.csv"
centers <- read_csv(centers_filename) %>%
  arrange(abbreviation)

isochrones <-list()
for(i in 1:length(iso0_4_15)) {
  isochrones[[i]] <-  rbind(iso0_4_15[[i]],iso5_8_1[[i]],iso10_16_2[[i]])
}


removeOverlap <- function(x) {
  message("x")
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

isochrones_no_overlap <- map(isochrones, removeOverlap)
names(isochrones_no_overlap) <- centers$abbreviation
saveRDS(isochrones_no_overlap, 'isochrones_no_overlap.rds')
