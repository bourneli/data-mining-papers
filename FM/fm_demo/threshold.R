
predAndLabel <- read.csv('data/fm_pred_label2.csv')
require(ggplot2)
qplot(prediction, data=predAndLabel)
summary(predAndLabel)

p <- ggplot(data = predAndLabel, aes(x=prediction, color = factor(label)))
p <- p + geom_density()
p <- p + scale_x_continuous(breaks = seq(0.4,0.65, by = 0.01))
p

base <- table(predAndLabel$label)
base_rate <- base['1'] / sum(base)
base_rate

t <- 0.492
predAndLabel$pLabel <- sapply(
  predAndLabel$prediction,
  function(x) ifelse(x>t,1,-1))
cm <- table(predAndLabel$pLabel, predAndLabel$label)
cm
precision <- cm['1','1'] / sum(cm['1',])
precision
recall <- cm['1','1'] / sum(cm[,'1'])
recall

lift <- precision / base_rate - 1
lift



require(MLmetrics)
max_pred <- max(predAndLabel$prediction)
min_pred <- min(predAndLabel$prediction)
predAndLabel$pValue <- (predAndLabel$prediction - min_pred)/(max_pred-min_pred) 
predAndLabel$label01 <- sapply(predAndLabel$label,function(x) ifelse(x>0,1,0))
 
require(ROCR)
my_pred <- prediction(predAndLabel$pValue, labels = predAndLabel$label01)
my_auc <- performance(my_pred, 'auc')
my_auc

my_roc <- performance(my_pred, measure = "tpr", x.measure = "fpr")
plot(my_roc)
abline(a=0, b= 1)



data(cars)
logreg <- glm(formula = vs ~ hp + wt,
              family = binomial(link = "logit"), data = mtcars)
AUC(y_pred = logreg$fitted.values, y_true = mtcars$vs)
