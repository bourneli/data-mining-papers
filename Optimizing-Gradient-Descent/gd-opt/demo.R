f <- function(x) -log(1-x)


x <- seq(0.000001,1,by=0.001)

d <- data.frame(x=x, y = sapply(x,f))
require(ggplot2)
qplot(x=x,y=y,data=d,geom='line')
