The different activities done on the analysis are the following (the same step numbers are included on the R script to easily map this explanation with the lines of codes related)

0. Folder preparation and download of the data. As it's a zip file it's also uncompressed. The script check if the file already exists to do not download it again. It also defines the path (DSPath) to to uncompressed folder to be used later to load the data.
1. The information is loaded using read.table function and column names are updated accordingly to Features and activity label. Then a single dataset (singleDS) is created using cbind and rbind. All temporal variables are removed to free up the memory.
2. To extract only the measurements on the mean and standard deviation for each measurement, a logical vector is created  from the colunms vector (cols). That vector is then used to subsetted the requested columns to a new dataset called singleDSMeanStandDev
3. Using the merge function we added the descriptive activity names to the data set. The result is a new dataset called singleDSMeanStandDev2.
4. On this step, some tidying is done on the name of the columns using gsub.
5. Finally a new dataset is created based on singleDSMeanStandDev2. We group by activityID and by subjectID in order to calculate the mean. The final result is saved on this (FinalTidyData.txt) using write.table function.
