




setwd("C:/Users/dd-sa/OneDrive/Documents/GitHub/introtodatamining/dataminingproject/R")

dataFile = "supermarket.txt"
marketData=as.data.frame(read.table(dataFile))
aData=subset(marketData,marketData[2]=="A")
bData=subset(marketData,marketData[2]=="B")
cData=subset(marketData,marketData[2]=="C")

firstHalf=marketData[1:500,c(5,14,16,17)]
secondHalf=marketData[501:1000,c(5,14,16,17)]


Xtrain =firstHalf
Xtrain[,2:4]=lapply(Xtrain[,2:4], function(x) as.numeric(as.character(x)))
n = dim(Xtrain)[1]
d = dim(Xtrain)[2]
# the last attribute is the class label, so it does not count.
#Training... Collect mean and standard deviation for each dimension for each class..
#Also, calculate P(C+) and P(C-)



idp = which(Xtrain[,1] =="Male") # points that have 1 as the class label
np = length(idp)
Xpositive = Xtrain[idp,2:d]
avgPositive=colMeans(Xpositive)

sdp=apply(Xpositive,2,sd)

idn = which(Xtrain[,1] =="Female")

pn=length(idn)/n
Xnegative= Xtrain[idn,2:d]
avgNegative=colMeans(Xnegative)
sdn=apply(Xnegative,2,sd)

#Testing .....
Xtest=secondHalf
Xtest[,2:4]=lapply(Xtest[,2:4], function(x) as.numeric(as.character(x)))
nn = dim(Xtest)[1] # Number of points in the testing data.


tp = 0 #True Positive
fp = 0 #False Positive
tn = 0 #True Negative
fn = 0 #False Negative


for (i in 1:nn) {

  #For each point find the P(C+|Xi) and P(C-|Xi) and decide if the point belongs to C+ or C-..
  #Recall we need to calculate P(Xi|C+)*P(C+) ..
  #P(Xi|C+) = P(Xi1|C+) * P(Xi2|C+)....P(Xid|C+)....Do the same for P(Xi|C-)
  #Now that you've calculate P(Xi|C+) and P(Xi|C-), we can decide which is higher
  #P(Xi|C-)*P(C-) or P(Xi|C-)*P(C-) ..
  #increment TP,FP,FN,TN accordingly, remember the true lable for the ith point is in Xtest[i,(d+1)]

  pv=dnorm(Xtest[i,d],avgPositive,sdp )

  PxPos=prod(pv)
  productPos=prod(PxPos,np)
  nv=dnorm(Xtest[i,d],avgNegative,sdn )
  PxNeg=prod(nv)
  productNeg=prod(PxNeg,pn)

  if(productPos >= productNeg){
    expectVal=1
  }else{expectVal=-1}
  if(Xtest[i,1]=="Male"){
    if(expectVal==1){
      tp=tp+1
    }else{
      fp=fp+1
    }
  }
  else{
    if(Xtest[i,1]=="Female"){
      tn=tn+1
    }else{
      fn=fn+1
    }
  }
}


#Calculate all the measures required..
Accuracy=(tp+tn)/(tp+fp+tn+fn)
precision=(tp)/(tp+fp)
recall=(tp)/(tp+fn)
testData <- matrix(c(Accuracy, tp, tn, fp, fn, precision, recall),ncol=7, byrow = TRUE)
colnames(testData)<-c("Accuracy", "TP","TN","FP", "FN", "Precision", "Recall")
testData <- as.table(testData)
testData

write.table(testData, file = "testRatingsData.txt", sep = "\t",
            row.names = TRUE, col.names = NA)