#'
#'# Lesson 1. Using bulk/regular download in COMTRADE
#'  
#'  
#'## Regular CT download
#'  
#'  Regular download is awailable at https://comtrade.un.org/data/ . 
#'  This is a querry / (API call not covered here) based approach to load CT 
#'  data selecting specific range of parameters. It returns a CSV file and could 
#'  be made manually and incereted in the R code manually.  
#'  
#'  Using https://comtrade.un.org/data/, load the fopllowing data:
#'  
#'  * Type of product: Goods
#'  * Frequency: Annual
#'  * HS: As reported (Most frequently used by as as it combines all codes that were ever recorded)
#'  * Period: 2014-2016
#'  * Reporter: Finland
#'  * Partners: World, USA
#'  * Trade flow: All
#'  * HS (as reported) commodity codes: Total, any 2,4 and 6 digits code (11, 1101, 110100)  
#'  
#'  Load this all data in R using tools available in the `base` package. Could be made like this but sometimes not efficient. 
#'  Try always use `stringsAsFactors = FALSE` because having too many factors variables may complecate your work.
#+ 
file <- "01-data-import/ct_regilar_extraction.csv"
ctData <- read.csv(file, stringsAsFactors = FALSE) # No extra parameters generally works fine.
names(ctData)     # See names of all variales
#+ eval=FALSE
head(ctData)     # See first 5 rows of the data frame
tail(ctData)     # See last 4 rows of the data frame
str(ctData)     # See structure of the data object
class(ctData)     # See the class of the data object

#' Doing the same using mode user friendly tools from the `tidyverse`
#+
library(tidyverse)  # Setups
library(readr)      # Setups
ctData <- read_csv(file) 
#' Using `read_csv()` returns a tbl_df() or tibble object that allows you 
#'    to explore all variables of the dataframe without printing it all in the console.
#'    no need to use head, tail, str.
#+
ctData  

#'## Bulk CT download
#'  
#'  Bulk download is available using the web page https://comtrade.un.org/data/bulk.
#'  
#'   There are two options how to access data here:
#'   * Web based querry with the help of the mouse in the bowser https://comtrade.un.org/data/bulk
#'   * API call based approach to load CT data. Used constructs a querry such as 
#'   "http://comtrade.un.org/api/get/bulk/C/A/1994/251/HS" following the 
#'   guidlines here https://comtrade.un.org/data/doc/api/bulk/
#'   
#'  To request bulk data file we need to following specific format explained in the COMTRADE:
#'  http://comtrade.un.org/api/get/bulk/{type}/{freq}/{ps}/{r}/{px}?{token=} , where 
#'  type (trade type), freq (frequency), ps (period), r (reporter), px (classification), and optionally token (see authentication).
#'  
#'  Using the web interface download data for France annual trade of commodities in 1994. 
#'  
#'  The file returned by the COMTRADE has name "type-C_r-251_ps-1994_freq-A_px-HS_pub-20020901_fmt-csv_ex-20150310.zip"
#'  The zip archive contains the file "type-C_r-251_ps-1994_freq-A_px-HS_pub-20020901_fmt-csv_ex-20150310.csv" with data.
#'  Attention! Data files could be VERY HEAVY (up to 9-10 GB). This lead to the difficulties in loading them. 
#'  
#'  The same file could have beet obtained from the querry "http://comtrade.un.org/api/get/bulk/C/A/1994/251/H".
#'  
#'  Reading zipped data file into R.
#'  
#'### Option one. Manually unzip BULK COMTRADE data file 
#'  
#'  Here we Manually unzip BULK COMTRADE data file into the same folder and read in the way as it was done before.
#+
file <- "01-data-import/type-C_r-251_ps-1994_freq-A_px-HS_pub-20020901_fmt-csv_ex-20150310.csv"
ctFranceData <- read_csv(file, guess_max = 1000000) # guess_max = 1000000 is used to avoid useless warninggs.
ctFranceData

#' To speed up the reading process, in the package `tradeAnalysis` there is a function `readCTCSV()`
#' which does reading of the bulk downloaded COMTRADE data file and convert all columns 
#' into propper format as well as remove all irrelevant columns and formats. 
#' The package `tradeAnalysis` could be installed in the following way:
#+ chunck1, eval=FALSE
install.packages("devtools")
devtools::install_github("EBukin/tradeAnalysis-pack")
#+
library(tradeAnalysis)

#' Reading files is done as:
#+
ctFranceData_2 <- readCTCSV(file)

#' The file is slightly lighter and is loaded faster. It is especially important when loaded files are 4 and more GB in volume.
#+
ctFranceData_2

#'### Option two. Unzip and read bulik COMTRADE data file in R.
#' 
#' To load bulk CT data file into R directly from the ZIP archive, we need to use 
#' package `tradeAnalysis`. In `tradeAnalysis` library, we use the following function `readCTZIP`.
#' To learn more about the syntaxis of the function `readCTZIP()` run `?readCTZIP`, 
#' to see the source code run `readCTZIP` of select `readCTZIP` with the mouse and press `F2`.
#+
ctFranceData_3 <- readCTZIP(folder = "01-data-import/", "type-C_r-251_ps-1994_freq-A_px-HS_pub-20020901_fmt-csv_ex-20150310.zip", delete = F)
ctFranceData_3
all_equal(ctFranceData_2, ctFranceData_3)

#'## Accessing to the links of all possible bulk download files and all available data.
#' 
#' In R we can see all available data files. To do that we use the COMTRADE API interface (https://comtrade.un.org/data/doc/api/bulk/#DataRequests).
#' 
#' Run the command "http://comtrade.un.org/api//refs/da/bulk?parameters" in the browser 
#' and after a while you will be returned with the JSON object with thousand rows of text. This Object could be 
#' parsed in R into a dataframe that will show all data available in COMTRADE and all querry commands needed to download each data file. 
#' 
#' To load this object into R we can do the following:
#+ chunck2, eval=FALSE
install.packages("jsonlite")
#+ 
library(jsonlite)
availableCtData_1 <- jsonlite::fromJSON("http://comtrade.un.org/api/refs/da/bulk?parameters") %>% tbl_df()
availableCtData_1

#' This table allows us to see what are the reporters ('r' variable) with the available data and what data exactly is available. 
#+
glimpse(availableCtData_1)

#' The variable `downloadUri` provides a COMTRADE querry (such as "/api/get/bulk/C/A/2016/428/H0") 
#' that could be combined together with "http://comtrade.un.org/" into one comand "http://comtrade.un.org/api/get/bulk/C/A/2016/428/H0"
#' and will return zipped datafile.
#' 
#' The same list of available bulk data in COMTRADE could be accessed with `getCTParameters()`
#' This approach modefies some variables into more user friendly. 
#+ eval=FALSE
library(tradeAnalysis)
availableCtData_2 <- getCTParameters()

#'## Downloading COMTRADE bulk data from the internet with R
#' 
#' To donload CT bulk ZIP data with R, we can use functoin available in the `tradeAnalysis` package.
#' 
#' To do the download, you need the data table of available data, loaded with `getCTParameters()`, 
#' selection of one particular row ot of it with the exact name of the country that you want to download,
#' and the destination folder.
#' 
#' See the following example. 
#' 
#' We want to download data about all annual trade of commodities by Ukriane (reporter code 804) in 2014 in the HS As reported classification.
#' To see extensive list of reporters and their codes, use `tradeAnalysis::getCTReporters()`
#+
library(tidyverse) 

#' Creating one line:
#' (In one of the following lessons the usafe of the 'filter' function will be discussed with mode details)
#+ eval=FALSE
oneLine <- 
  filter(availableCtData_2,
                  r == 804, 
                  type == "COMMODITIES", 
                  freq == "ANNUAL",
                  year == 2014,
                  px == "HS")

#' Loading one data file:
#' 
#' Explore more about the `token` parameter with `?downloadCTZIP`
#+ eval=FALSE
downloadCTZIP(df = oneLine, toFolder = "01-data-import/", token = NA)

