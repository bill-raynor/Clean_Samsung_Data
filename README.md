# Loading and Summarizing the SAMSUNG Data Set #

There is a single script *run_analysis.R* that reads the data from an **existing** directory labelled **UCI HAR Dataset.** It produces an intermediate dataset and a summary dataset entitled *tidy_data* as well as a text dump of that file. The intermediate dataset, labelled "Step_4_data" includes the mean() and std() variables included in the original sensor data sets. 

To run the script:

   1. cd to the directory containing the *UCI HAR Dataset* directory as well as the R script *run_analysis.R*. If the data has not yet been downloaded, download the zip file and expand in the directory containing the R script.
 2.  start R or RStudio
 3.  open "run_analysis.R" and submit the script. Note the the script will attempt to download and install the *dplyr* and *tidyr* packages if they are not already in the library. 

