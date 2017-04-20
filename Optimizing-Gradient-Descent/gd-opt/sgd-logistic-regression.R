############################################################
# 尝试SGD在线性规划上的收敛效果
############################################################

require(ggplot2)
source('common.R',encoding = 'utf8')



# 准备数据
my_x <- t(as.matrix(cbind(1,iris[,1:4])))
my_y <- ifelse(iris$Species == 'setosa',1,0)
set.seed(1234)
my_w <- as.matrix(rnorm(5))


# 测试效果
logistic_regression_gradient_single(my_x, my_y, my_w, 2)
logistic_regression_gradient_batch(my_x, my_y, my_w)
linear_regression_cost(my_x,my_y,my_w)

# 公共参数
max_iter <- 2500
learn_rate <- 0.0001

################################################
# 批量梯度递减
################################################
my_gd <- gd(
  gradient_fun = logistic_regression_gradient_batch,
  cost_fun = logistic_regression_cost
)
rst_gd <- my_gd(my_x,my_y,my_w,learn_rate, max_iter)
qplot(x=round, y = cost,data = rst_gd, geom = 'line' )

################################################
# 随机梯度递减 
################################################
my_sgd <- sgd(
  gradient_fun = logistic_regression_gradient_single, 
  cost_fun = logistic_regression_cost
)
rst_sgd <- my_sgd(my_x,my_y,my_w,learn_rate, max_iter)
qplot(x=round, y = cost,data = rst_sgd, geom = 'line' )


# 观察两个算法cost的收敛速度
combine_result <- rbind(rst_gd, rst_sgd)
p <- ggplot(combine_result, aes(x=round,y = cost,color = type))
p <- p + geom_line()
p

################################################
# 动量梯度递减 
################################################
my_gd_m <- gd_momentum(
  gradient_fun = logistic_regression_gradient_batch,
  cost_fun = logistic_regression_cost
)
rst_gd_m <- my_gd_m(
  my_x,
  my_y,
  my_w,
  alpha=learn_rate,
  p=0.1, 
  maxIter = max_iter
)

# 观察三个算法cost的收敛速度
combine_result <- rbind(
  rst_gd, 
  rst_sgd, 
  rst_gd_m
)
p <- ggplot(combine_result, aes(x=round,y = cost,color = type))
p <- p + geom_line()
p


################################################
# 动量随机梯度递减 
################################################
my_sgd_m <- sgd_momentum(
  gradient_fun = logistic_regression_gradient_single,
  cost_fun = logistic_regression_cost
)
rst_sgd_m <- my_sgd_m(
  my_x,
  my_y,
  my_w,
  alpha = learn_rate,
  p=0.25, 
  max_iter = max_iter
)
qplot(x=round, y = cost,data = rst_sgd_m, geom = 'line' )
summary(rst_sgd_m)

# 观察四个算法cost的收敛速度
combine_result <- rbind(
  rst_gd, 
  rst_sgd, 
  rst_gd_m,
  rst_sgd_m
)
p <- ggplot(combine_result, aes(x=round,y = cost,color = type))
p <- p + geom_line()
p <- p + scale_y_continuous(limits = c(0, max(combine_result$cost)))
p

ggsave(p,file='converage_logistic_regression_4.png',width=8,height=6)




