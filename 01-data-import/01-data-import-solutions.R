#'
#'# Lesson 1. Using bulk/regular download in COMTRADE
#'  
#'  
#'## Regular CT download
#'  
#'  Regular download is available at https://comtrade.un.org/data/ . 
#'  This is a query / (API call not covered here) based approach to load CT 
#'  data selecting a specific range of parameters. It returns a CSV file, could 
#'  be made manually and inserted in the R code manually.  
#'  
#'  Using https://comtrade.un.org/data/, load the following data:
#'  
#'  * Type of product: Goods
#'  * Frequency: Annual
#'  * HS: As reported (Most frequently used as it combines all codes that were ever recorded)
#'  * Period: 2014-2016
#'  * Reporter: Finland
#'  * Partners: World, USA
#'  * Trade flow: All
#'  * HS (as reported) commodity codes: Total, any 2, 4 and 6 digits code (11, 1101, 110100)  
#'  
#'  Load this data in R using the tools available in the `base` package. We can use base package, but sometimes, it is not efficient. 
#'  Try to always use `stringsAsFactors = FALSE` because having too many factors variables may complicate your work.
#+ 
file <- "01-data-import/ct_regular_extraction.csv"
ctData <- read.csv(file, stringsAsFactors = FALSE) # No extra parameters; generally works fine.
names(ctData)     # See the names of all variables
#+ eval=FALSE
head(ctData)     # See the first 5 rows of the data frame
tail(ctData)     # See the last 4 rows of the data frame
str(ctData)     # See the structure of the data object
class(ctData)     # See the class of the data object

#' Doing the same using user friendly tools from the `tidyverse`
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
#'   * Web based query with the help of the mouse in the browser https://comtrade.un.org/data/bulk
#'   * API call based approach to load CT data. Used constructs a query such as 
#'   "http://comtrade.un.org/api/get/bulk/C/A/1994/251/HS" following the 
#'   guidelines here https://comtrade.un.org/data/doc/api/bulk/
#'   
#'  To request a bulk data file we need to use the following specific format explained in the COMTRADE:
#'  http://comtrade.un.org/api/get/bulk/{type}/{freq}/{ps}/{r}/{px}?{token=} , where 
#'  type (trade type), freq (frequency), ps (period), r (reporter), px (classification), and optionally token (see authentication).
#'  
#'  Using the web interface download data for France’s annual trade of commodities in 1994. 
#'  
#'  The file returned by the COMTRADE has name "type-C_r-251_ps-1994_freq-A_px-HS_pub-20020901_fmt-csv_ex-20150310.zip"
#'  The zip archive contains the file "type-C_r-251_ps-1994_freq-A_px-HS_pub-20020901_fmt-csv_ex-20150310.csv" with data.
#'  Attention! Data files could be VERY HEAVY (up to 9-10 GB). This may lead to difficulties in loading them. 
#'  
#'  The same file could have been obtained from the query "http://comtrade.un.org/api/get/bulk/C/A/1994/251/H".
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
#' into proper format as well as remove all irrelevant columns and formats. 
#' The package `tradeAnalysis` could be installed in the following way:
#+ chunck1, eval=FALSE
install.packages("devtools")
devtools::install_github("EBukin/tradeAnalysis-pack")
#+
library(tradeAnalysis)

#' Reading files is done as:
#+
ctFranceData_2 <- readCTCSV(file)

#' The file is slightly lighter and is loaded faster. It is especially important when loaded files are 4 or more GB in volume.
#+
ctFranceData_2

#'### Option two. Unzip and read bulk COMTRADE data file in R.
#' 
#' To load bulk CT data file into R directly from the ZIP archive, we need to use 
#' the `tradeAnalysis` package. In the `tradeAnalysis` library, we use the function `readCTZIP`.
#' To learn more about the syntax of the `readCTZIP()`function run `?readCTZIP`, 
#' to see the source code run `readCTZIP`, or select `readCTZIP` with the mouse and press `F2`.
#+
ctFranceData_3 <- readCTZIP(folder = "01-data-import/", "type-C_r-251_ps-1994_freq-A_px-HS_pub-20020901_fmt-csv_ex-20150310.zip", delete = F)
ctFranceData_3
all_equal(ctFranceData_2, ctFranceData_3)

#'## Accessing the links of all possible bulk download files and all available data.
#' 
#' In R we can see all available data files. To do that we use the COMTRADE API interface (https://comtrade.un.org/data/doc/api/bulk/#DataRequests).
#' 
#' Run the command "http://comtrade.un.org/api//refs/da/bulk?parameters" in the browser 
#' and after a while you will be returned the JSON object with thousands of rows of text. This Object could be 
#' parsed in R into a dataframe that will show all data available in COMTRADE and 
#' all query commands needed to download each data file. 
#' 
#' To load this object into R we can do the following:
#+ chunck2, eval=FALSE
install.packages("jsonlite")
#+ 
library(jsonlite)
availableCtData_1 <- jsonlite::fromJSON("http://comtrade.un.org/api/refs/da/bulk?parameters") %>% tbl_df()
availableCtData_1

#' This table allows us to see what the reporters are ('r' variable) with the available data and what data exactly is available. 
#+
glimpse(availableCtData_1)

#' The variable `downloadUri` provides a COMTRADE query (such as "/api/get/bulk/C/A/2016/428/H0") 
#' that can be combined into one command together with http://comtrade.un.org/. 
#' The result would look something like "http://comtrade.un.org/api/get/bulk/C/A/2016/428/H0"
#' and will return a zipped data file.
#' 
#' The same list of available bulk data in COMTRADE can be accessed with `getCTParameters()`
#' This approach makes some of the variables more user friendly. 
#+ eval=FALSE
library(tradeAnalysis)
availableCtData_2 <- getCTParameters()

#'## Downloading COMTRADE bulk data from the internet with R
#' 
#' To download CT bulk ZIP data with R, we can use a function available in the `tradeAnalysis` package.
#' 
#' To do the download, you need the data table of available data, loaded with `getCTParameters()`, 
#' selection of one particular row out of it with the exact name of the country that you want to download,
#' and the destination folder.
#' 
#' See the following example. 
#' 
#' We want to download data about all annual trade of commodities by Ukriane (reporter code 804) in 2014 in the HS ‘As reported’ classification.
#' To see an extensive list of reporters and their codes, use `tradeAnalysis::getCTReporters()`
#+
library(tidyverse) 

#' Creating one line:
#' (In one of the following lessons the usage of the 'filter' function will be discussed with more details)
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

#'  Parameter `token` is an important one, when you try to access to the COMTRADE data from outside of the FAO. If you want to access data from the outside, you need to register your email from the FAO in the COMTRADE system first and them save your token on the computer. Inserting your token to the filed `token` in the function ` downloadCTZIP()` will ensure that you can download CT data from the outside of FAO. 
#'  To generate token, you need first to go to the page https://comtrade.un.org/data/auth/login?ReturnUrl=%2Fdata%2Fbulk 
#'  and incert your email into the `Sign in using:` `IP Authentication:` field. 
#'  Press `Authenticate my IP` and the system will register you. Then you need 
#'  to go the page https://comtrade.un.org/api/swagger/ui/index#/ and select the 
#'  subsection `/getSubUserToken` - To get authentication token when the request 
#'  is originated from registered IP range. Email parameters required. 
#'  Insert your email into the corresponding field and press "try it out". In the 
#'  "Response body" there will be a token with the length of around 128 symbols. 
#'  Copy this token to the secure place and use it to access data as following:
#+ eval=FALSE
downloadCTZIP(df = oneLine, toFolder = "01-data-import/", token = "token_content_as_it_is_in_comtrade")




