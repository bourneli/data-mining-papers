loss <- read.csv('clipboard')
loss$round <- 1:nrow(loss)
# loss$step_size <- 0.5
# write.csv(loss,'data/loss_with_a_deep_curve.csv')


require(ggplot2)
p <- qplot(x=round,y=loss, data = loss, geom = 'line')
 # p <- p + scale_y_continuous(limits = c(0,2))
p <- p + ggtitle('auc = 0.623')
p
ggsave(p,file='loss_curve.png')

label <- -1
pred <- 9.473893840215117E92
log(1+exp(-label*pred))
