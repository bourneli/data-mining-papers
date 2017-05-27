require(ggplot2)

alpha <- function(error) {
  log((1-error)/error)
}


x <- seq(0.00001,0.999999,by = 0.001)

d <- data.frame(x = x, y = sapply(x,alpha))


qplot(x,y,data=d,geom='line')

# 当前分类器很强，但是却把这个实例搞错了，那么这个实例确实很复杂，要加强权重
# 当前分类器很弱，把这个实例搞错了，可以理解，权重减轻。
