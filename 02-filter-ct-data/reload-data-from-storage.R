

# Script for reloading data from the storage
library(tidyverse)
library(tradeAnalysis)

ctData <-
  tradeAnalysis::load_ct_rdata(
    rootFolder = "~/ctData/ctBulkR/ctAnAll/wtoAnAll/",
    period = c(2010:2016))


ctDataShort <-
  ctData %>%
  filter(
    Commodity.Code %in% filter(
      wtoAgFoodFull,
      prime |
        cc1 %in% filter(wtoAgFoodFull, prime, cc2 == "")$cc1 &
        cc3 == "" &
        cc2 != ""
    )$Commodity.Code
  ) %>%
  flt_year_ct(2014:2016) %>%
  select(
    Classification ,
    Year,
    Trade.Flow.Code,
    Reporter.Code,
    Partner.Code,
    Commodity.Code,
    Netweight..kg.,
    Trade.Value..US..
  )

write_rds(ctDataShort, "02-filter-ct-data/subsetting-data.rds", compress = "gz")

