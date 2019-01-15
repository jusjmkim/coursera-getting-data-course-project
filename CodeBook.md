# Getting and Cleaning Data Course Project Code Book

## The Data
Data were pulled and compiled from the `UCI HAR Dataset`. In the case of `master_data_table_avg`, averages of all feature data variables were taken by subject and by activity. Exported file versions of these datasets can be found in `master_data_table.txt` and `master_data_table_avg.txt`.

## Variables

### subjectid
Type numeric. These ids range from 1 to 30 and correspond with a unique subject

### activity
Type character. There are six types: WALKING, WALKING\_UPSTAIRS, WALKING\_DOWNSTAIRS, SITTING, STANDING, and LAYING. These each correspond to a type of activity the subject was performing when movement data were measured.

### feature data variables
Type numeric. Of the 561 feature variables that were available, only the ones with "mean" and "std" in the variable names were collected and captured in the exported datasets, resulting in 79 feature variables of interest. These were recorded for each subject by activity for each time period in which data were collected. Note: each feature was already normalized and bounded with [-1, 1].
