#For removing pre-clap data from FIT videos 

#Insert packages here 
library(tidyverse)
library(readr)

#Paths: change these as needed 
raw_csv_path <- "/data/netapp02/work/Manvi_Sethi/FIT/raw_csvs/"
clean_csv_path <- "/data/netapp02/work/Manvi_Sethi/FIT/clap_trimmed_csvs/"
timestamp_data_path <- "/data/netapp02/work/Manvi_Sethi/FIT/timestamp_data.csv"

# Creates a vector of CSV filenames to be processed 
csvs <- list.files(path = raw_csv_path)

#read in timestamp CSV (save this in the same wd for ease)
timestamp_data <- read_csv(timestamp_data_path) %>%
  as.data.frame()

#removes any NA/#VALUE! cells from data frame and reads values as numeric variables
timestamp_data_clean<- timestamp_data[!timestamp_data$endtime=="#VALUE!",]
timestamp_data_clean$endtime <- as.numeric(as.character(timestamp_data_clean$endtime))

#timing how long process takes 
system.time({
  
  #loop begins here, make sure to change number depending on how many CSVs are being edited 
  lapply(csvs, function(csv){
    #removing .csv from string of CSV file names earlier created 
    F <- str_remove(csv, ".csv")
    
    #Using 
    L <- grep(F, timestamp_data_clean$pid)
    
    #retrieving clap time from timestamp CSV 
    ct <- timestamp_data_clean[L,"claptime"]
    
    #retrieving end time from timestamp CSV 
    et <- timestamp_data_clean[L, "endtime"]
    
    #reading in raw CSV 
    raw_csv <- read_csv(file.path(raw_csv_path, csv)) %>% 
      as.data.frame()
    
    #trimming CSV
    clean_csv<- subset(raw_csv, timestamp >= ct) 
    
    #Clean path - change this according to where clean CSVs should be going 
    clean_path <- file.path(clean_csv_path, paste(F, "_cltr.csv", sep = ""))
    
    write.csv(clean_csv, clean_path)
  })
})


