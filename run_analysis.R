##### 0. Download and unzip data
if(!file.exists("data")){
  dir.create("data")
}

ZipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
ZipPath <- "./data/UCI_HAR-Dataset.zip"
if(!file.exists(ZipPath)){
  download.file(ZipUrl, ZipPath, method = "curl")
}

#Init path to unzipped files
DSPath = file.path("./data/UCI HAR Dataset")
if(!file.exists(DSPath))
{
  unzip(zipfile=ZipPath,exdir="./data")
}



##### 1. This script will create a single dataset by merging the train and test datasets
#contained on the UCI HAR Dataset

#Read the features data
feat = read.table(file.path(DSPath, "features.txt"),header = FALSE)
#Read activity labels
activLabel = read.table(file.path(DSPath, "activity_labels.txt"),header = FALSE)
#Add most readable colunms name
colnames(activLabel) <- c('activityId','activityType')


# Training data set loading and tidying 
#Read tables for train x, y  and subject
xtrain = read.table(file.path(DSPath, "train", "X_train.txt"),header = FALSE)
ytrain = read.table(file.path(DSPath, "train", "y_train.txt"),header = FALSE)
strain = read.table(file.path(DSPath, "train", "subject_train.txt"),header = FALSE)
#Add most useful names for columns
colnames(xtrain) = feat[,2]
colnames(ytrain) = "activityId"
colnames(strain) = "subjectId"


# Test data set loading and tidying 
#Read tables for test x, y and subject
xtest = read.table(file.path(DSPath, "test", "X_test.txt"),header = FALSE)
ytest = read.table(file.path(DSPath, "test", "y_test.txt"),header = FALSE)
stest = read.table(file.path(DSPath, "test", "subject_test.txt"),header = FALSE)
#Add most useful names for columns
colnames(xtest) = feat[,2]
colnames(ytest) = "activityId"
colnames(stest) = "subjectId"


#Merging the train and test data - important outcome of the project
trainingDS = cbind(ytrain, strain, xtrain)
testDS = cbind(ytest, stest, xtest)

#Create the main data table merging both table tables - this is the outcome of 1
singleDS = rbind(trainingDS, testDS)
# Prepare data for subsetting (create vector with column names)
cols = colnames(singleDS)

#Delete temporal datasets to free up memory
rm(xtrain,ytrain,strain,xtest,ytest,stest,trainingDS,testDS)


####2. Extracts only the measurements on the mean and standard deviation for each measurement

#Logical vector with all trues on columns with ID, subject, mean and standard deviation 
vector = (grepl("activityId" , cols) | grepl("subjectId" , cols) | grepl("mean.." , cols) | grepl("std.." , cols))

#Subset with the above restrictions
singleDSMeanStandDev <- singleDS[ , vector == TRUE]



##### 3. Uses descriptive activity names to name the activities in the data set

singleDSMeanStandDev2 <- merge(singleDSMeanStandDev,activLabel,by='activityId',all.x=TRUE);
singleDSMeanStandDev2$activityId <-activLabel[,2][match(singleDSMeanStandDev2$activityId, activLabel[,1])] 


#####4.	Appropriately labels the data set with descriptive variable names

#load colunm names
colunms <- colnames(singleDSMeanStandDev2)

#Removing abbreviatures, using same letter case, and add better descriptions
for (i in 1:length(colunms)) 
{
  colunms[i] <- gsub("\\()","",colunms[i])
  colunms[i] <- gsub("-std$","StdDev",colunms[i])
  colunms[i] <- gsub("-mean","Mean",colunms[i])
  colunms[i] <- gsub("^(t)","time",colunms[i])
  colunms[i] <- gsub("^(f)","freq",colunms[i])
  colunms[i] <- gsub("([Gg]ravity)","Gravity",colunms[i])
  colunms[i] <- gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",colunms[i])
  colunms[i] <- gsub("[Gg]yro","Gyro",colunms[i])
  colunms[i] <- gsub("AccMag","AccMagnitude",colunms[i])
  colunms[i] <- gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",colunms[i])
  colunms[i] <- gsub("JerkMag","JerkMagnitude",colunms[i])
  colunms[i] <- gsub("GyroMag","GyroMagnitude",colunms[i])
};

# Update singleDSMeanStandDev2 with new descriptive column names
colnames(singleDSMeanStandDev2) <- colunms



##### 5.	From the data set in step 4, creates a second, independent tidy data set 
#with the average of each variable for each activity and each subject.

# Averaging each activity and each subject as Tidy Data
GroupedDS <- aggregate(singleDSMeanStandDev2[,names(singleDSMeanStandDev2) != c('activityId','subjectId')]
                       ,by=list(activityId=singleDSMeanStandDev2$activityId,
                                subjectId=singleDSMeanStandDev2$subjectId)
                       ,mean);

# Export GroupedDS set 
write.table(GroupedDS, './FinalTidyData.txt',row.names=FALSE,sep='\t')


# Averaging each activity and each subject as Tidy Data
GroupedDS <- aggregate(singleDSMeanStandDev2[,names(singleDSMeanStandDev2) 
                                             != c('activityId','subjectId')],by=list
                       (activityId=singleDSMeanStandDev2$activityId,
                         subjectId=singleDSMeanStandDev2$subjectId),mean);

# Export GroupedDS set to a final file
write.table(GroupedDS, './data/TidyData.txt',row.names=FALSE,sep='\t')



