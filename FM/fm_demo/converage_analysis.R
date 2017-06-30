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



my_loss <- read.csv('clipboard')
require(reshape2)
my_loss$r <- 1:nrow(my_loss)

my_loss_v <- melt(my_loss, id.vars = 'r')
names(my_loss_v) <- c('round','loss_type','loss')


require(ggplot2)
p <- ggplot(my_loss_v, aes(x = round, y=loss, color = loss_type))
p <- p + geom_line()
p <- p + facet_wrap(~loss_type)
p

