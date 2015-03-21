# Getting and Cleaning Data (012) - Course Project
# W.J.Raynor
#
# Summary
# You should create one R script called run_analysis.R that does the following. 
#   1. Merges the training and the test sets to create one data set.
#   2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#   3. Uses descriptive activity names to name the activities in the data set
#   4. Appropriately labels the data set with descriptive variable names. 
#   5. From the data set in step 4, creates a second, independent tidy data set with the average 
#      of each variable for each activity and each subject.

# Step 1
# The data are stored in the unzipped "UCR HAR Dataset" directory within the current working directory.
# Within that directory there are two subdirectories "test" and "train". Each of these subdirectories
# has three data files and a further subdirectory of "Intertial Signals". Read each of the txt files
# within the test and train directories and merge together into a test_data and train_data. 
# 


# Step 0 - Test for directories
# THIS SCRIPT ASSUMES THAT THE DATA HAS BEEN DOWNLOADED AND UNZIPPED IN THE CURRENT WORKING DIRECTORY.
# the following lines test that
directory <- "UCI HAR Dataset"
stopifnot(file.exists(directory))
stopifnot(file.exists(file.path(directory,"test")))
stopifnot(file.exists(file.path(directory,"train")))

# ------------------------------------------------------------------------------------------
# Step 1 - Merges the training and the test sets to create one data set.
# ------------------------------------------------------------------------------------------

# Read Test data - use file.path() to avoid Windows/Unix difficulties 
# the test and training data is spread across multiple datasets. This 
# is a "one type in multiple tables" in section 3.5 of tidy data paper.
# Read each of the test and train files, and combine into one data frame.
x_test <- read.table(file.path(directory,"test","X_test.txt"))
activity_test <- read.table(file.path(directory,"test","y_test.txt"), col.names=c("Activity"))
subject_test <- read.table(file.path(directory,"test","subject_test.txt"), col.names=c("Subject"))
#   "add a new column that records the original file name" - this case, record the directory
group <-data.frame(rep("test", nrow(activity_test)))
names(group)<- c("Group")
test_data <- cbind(group,subject_test, activity_test, x_test )

# Repeat for the train data  
x_train <- read.table(file.path("UCI HAR Dataset","train","X_train.txt"))
activity_train <- read.table(file.path(directory,"train","y_train.txt"), col.names=c("Activity"))
subject_train <- read.table(file.path("UCI HAR Dataset","train","subject_train.txt"), col.names=c("Subject"))
group <-data.frame(rep("train", nrow(activity_train)))
names(group)<- c("Group")
train_data <- cbind(group,subject_train, activity_train, x_train )

Step_1_data <- rbind(test_data, train_data)
rm(list=ls(pattern="*_test"))
rm(list=ls(pattern="*_train"))
rm(group)
rm(foo)
rm(test_data)
rm(train_data)

# ------------------------------------------------------------------------------------------
# Step 2 - Extracts only the measurements on the mean and standard deviation for each measurement. .
# ------------------------------------------------------------------------------------------

# read the feature data and extract the feature_names
features <- read.table(file.path(directory,"features.txt"), col.names=c("Data_Col", "Col_Name"))
features <- c("Group","Subject", "Activity", as.vector(features[,"Col_Name"]))

# create a logical vector of the columns that are to be extracted. TRUE: kept, FALSE: dropped
toKeep <-grepl("Group|Subject|Activity|mean|std",features) & !grepl("meanFreq", features)

# Apply the logical vector to the Step 1 data set, to create the Step 2 data set
Step_2_data <-Step_1_data[,toKeep]

# ------------------------------------------------------------------------------------------
# Step 3 - Uses descriptive activity names to name the activities in the data set
# ------------------------------------------------------------------------------------------

# Convert the Activity variable, an integer, to a labelled factor
act <- read.table(file.path("UCI HAR Dataset","activity_labels.txt"), col.names=c("act_num", "act_lbl"))
actnum <- as.vector(act[,1])
actlbl <- as.vector(act[,2])
#   make the labels a little easier to read
#   from the inside out:
#     convert the underscore to space
#     convert the strings to lower case
#     convert to "proper case" using function from stackoverflow.com
actlbl <-gsub("\\b([a-z])([a-z]+)", "\\U\\1\\E\\2" ,tolower(gsub("_"," ",actlbl)), perl=TRUE)

## this converts the activity values to labelled factors
Step_3_data <-Step_2_data
Step_3_data[,"Activity"] <- factor(Step_2_data[,"Activity"], levels=actnum, labels = actlbl)

# clean up 
rm(list=ls(pattern="act*"))

# ------------------------------------------------------------------------------------------
# Step 4 - Appropriately labels the data set with descriptive variable names
# ------------------------------------------------------------------------------------------

# Step_3_data columns are labelled "Subject", "Activity", "V1", "V2", ...
# replace the V...  columns with descriptive variable names, based on the features.
# following "David's personal course project FAQ" in the discussion forums, We will NOT
# decompose the feature names, just tidy them up a bit, by dropping the extraneous "()" 
flist <-gsub("\\(\\)","",features[toKeep])

Step_4_data <- Step_3_data
names(Step_4_data) <- flist
rm(flist)

# ------------------------------------------------------------------------------------------
# Step  5 -From the data set in step 4, creates a second, independent tidy data set with the average 
#          of each variable for each activity and each subject.
# ------------------------------------------------------------------------------------------

# test to see if dplyr and tidyr are available. if not, install and load them
if (!require(dplyr)) {
  install.package("dplyr")
  library(dplyr)
}

if (!require(tidyr)) {
  install.package("tidyr")
  library(tidyr)
}

# Collapse the data into a (wide) tidy layout.
# one column for each measurement 
# one row for each observation ( a group x subject x activity triplet)

tidy_data <- tbl_df(Step_4_data) %>% 
  group_by(Group,Subject,Activity) %>%
  summarise_each(funs(mean))

write.table(tidy_data,file = "tidy_data.txt", row.name=FALSE)

# Clean up
rm(Step_1_data)   # initial merged data containing all 561 measurements
rm(Step_2_data)   # only the mean() and std() statistics 
rm(Step_3_data)   # activity converted to a factor
rm(toKeep)
rm(features)
# -----------------------------------------------------------------------
# End of script
##################################################################################################
