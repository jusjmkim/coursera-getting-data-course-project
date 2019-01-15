library(data.table)
library(dplyr)

data_dir <- "UCI HAR Dataset"

################# MERGE TESTING AND TRAINING DATA TOGETHER ####################

# Helper function to format file title appropriately
get_sub_file <- function(data_split, prefix) {
  paste(data_dir, data_split, paste0(prefix, data_split, ".txt"), sep = "/")
}

# Convert dictionary files into tables
convert_to_table <- function(txt_file) {
  data_labels <- strsplit(readLines(paste(data_dir, txt_file, sep = "/")), " ")
  data_table <- data.table(id = numeric(), activity = character())
  for(data_label in data_labels) {
    data_table <- rbindlist(list(data_table, list(as.numeric(data_label[1]), data_label[2])))
  }
  data_table
}

# Extract all activities from file and match with description
collect_descriptive_activities <- function(data_split) {
  activity_file <- get_sub_file(data_split, "y_")
  activity_labels <- as.numeric(readLines(activity_file))
  ## Assign descriptive activity names in data set
  activity_table[activity_labels]$activity
}

# Extract feature data from files
collect_feature_data <- function(data_split) {
  feature_file <- get_sub_file(data_split, "X_")
  raw_feature_data <- readLines(feature_file)
  cleaned_feature_data <- list()
  for (line in 1:length(raw_feature_data)) {
    split_line <- strsplit(raw_feature_data[line], " ")[[1]]
    valid_feature_data <- as.numeric(split_line[split_line != ""])
    names(valid_feature_data) <- full_features
    cleaned_feature_data[[line]] <- valid_feature_data
  }
  cleaned_feature_data
}

# Combine all subject ids, activities, and 561 features into one data set
compile_raw_data <- function(data_table, subjectids, activities, feature_data) {
  for (i in 1:length(subjectids)) {
    new_data <- data.table(subjectid = subjectids[i], activity = activities[i])
    subject_feature_data <- feature_data[i][[1]]
    for (colname in target_features) new_data[1,colname] <- subject_feature_data[colname][[1]]
    data_table <- rbind(data_table, new_data)
  }
  data_table
}

# Extract column names with 'mean' and 'std' in them
mean_std_cols <- function(colnames) {
  colnames[grep("mean|std", colnames)]
}

# Compile testing / training data across files
compile_subject_data <- function(data_split) {
  # Initialize data table
  data_table <- data.table(subjectid = numeric(), activity = character())
  for (element in target_features) data_table[,paste(element, collapse = " ")] <- NA
  
  # Get subjet IDs
  subject_file <- get_sub_file(data_split, "subject_")
  subjectids <- as.numeric(readLines(subject_file))
  
  # Extract activities and assign descriptive names
  activities <- collect_descriptive_activities(data_split)
  
  # Extract feature data
  feature_data <- collect_feature_data(data_split)
  
  # Add all data to a single table
  compile_raw_data(data_table, subjectids, activities, feature_data)
}

### Create libraries of labels of activities and features
activity_table <- convert_to_table("activity_labels.txt")
full_features <- strsplit(readLines(paste(data_dir, "features.txt", sep = "/")), " ")
full_features <- sapply(full_features, function(x) paste(x, collapse = " "))

## Specify extracting only mean and standard deviation calculations for each measurement
target_features <- mean_std_cols(full_features)
target_features <- sapply(target_features, function(x) paste(x, collapse = " "))

### Process testing and training data
testing_data_table <- compile_subject_data("test")
training_data_table <- compile_subject_data("train")

### Merge testing and training data together
master_data_table <- rbind(testing_data_table, training_data_table)
master_data_table <- arrange(master_data_table, subjectid, activity)
write.table(master_data_table, "master_data_table.txt", row.name = FALSE)

## CREATE A SECOND DATA SET WITH AVG OF EACH VARIABLE BY SUBJECT / ACTIVITY ##
master_data_table_avg <- calc_avg(master_data_table)
write.table(master_data_table_avg, "master_data_table_avg.txt", row.name = FALSE)

calc_avg <- function(data_table) {
  aggregate(data_table[,target_features], by = list(subjectid = data_table$subjectid, activity = data_table$activity), mean)
}

