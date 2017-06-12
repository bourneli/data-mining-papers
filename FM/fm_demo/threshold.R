
predAndLabel <- read.csv('d:/fm_pred_label2.csv')
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
