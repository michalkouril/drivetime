#!/usr/local/bin/Rscript

dht::greeting()

## load libraries without messages or warnings
withr::with_message_sink("/dev/null", library(dplyr))
withr::with_message_sink("/dev/null", library(tidyr))
withr::with_message_sink("/dev/null", library(sf))

doc <- "
Usage:
  entrypoint.R [--shiny] [<filename>]
  entrypoint.R (-h | --help)
   
Options:
  -h --help     Show this screen.
  --shiny       Start shiny server on port 3838.
"

opt <- docopt::docopt(doc)

if (opt$shiny) {
  shiny::runApp(appDir="shiny",port=3838)
}

iso_filename <- Sys.getenv("ISO_FILENAME", "./isochrones.rds")
centers_filename <- Sys.getenv("CENTERS_FILENAME", "./ctsa_centers.csv")
output_filename <- Sys.getenv("OUTPUT_FILENAME", "./output.csv")

## for interactive testing
## opt <- docopt::docopt(doc, args = 'test/my_address_file_geocoded.csv')

centers <- readr::read_csv(centers_filename) %>% arrange(abbreviation)
  
d <- dht::read_lat_lon_csv(opt$filename, nest_df = T, sf = T, project_to_crs = 5072)
isochrones <- readRDS(glue::glue(iso_filename))
dx<-sapply(isochrones, function(x) { st_join(d$d, x,largest = TRUE)$drive_time })
df<-as.data.frame(dx)
# colnames(df)[apply(df,1,which.max)]

mins <- apply(df,1,which.min)
not_found <- length(centers$abbreviation)+1
mins[is.na(mins == 0)]<-not_found
min_centers <- centers$abbreviation[unlist(mins)]

output <- cbind(d$raw_data,min_centers)
write.csv(output, file=output_filename)
