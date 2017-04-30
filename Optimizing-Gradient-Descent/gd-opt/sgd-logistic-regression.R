############################################################
# 尝试SGD在线性规划上的收敛效果
############################################################

require(ggplot2)
source('common.R',encoding = 'utf8')


# 试验函数
logistic_regression_experiment <- function(
  my_x,
  my_y,
  max_iter,
  learn_rate,
  p = 0.9,
  message = '') {
  
  my_w <- as.matrix(rnorm(nrow(my_x)))
  
  ################################################
  # 批量梯度递减
  ################################################
  my_gd <- gd(
    gradient_fun = logistic_regression_gradient_batch,
    cost_fun = logistic_regression_cost
  )
  rst_gd <- my_gd(my_x,my_y,my_w,learn_rate, max_iter)
  print("Complete GD")
  
  ################################################
  # 随机梯度递减 
  ################################################
  my_sgd <- sgd(
    gradient_fun = logistic_regression_gradient_single, 
    cost_fun = logistic_regression_cost
  )
  rst_sgd <- my_sgd(my_x,my_y,my_w,learn_rate, max_iter)
  print("Complete SGD")
  
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
    p=0.45, 
    maxIter = max_iter
  )
  print("Complete GD with Momentum")
  
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
    p=0.45, 
    max_iter = max_iter
  )
  print("Complete SGD with Momentum")
  
  
  
  # 观察四个算法cost的收敛速度
  title <- sprintf(
    '%s, iteration=%d, learn rate = %s, p = %s', 
    message,
    max_iter,
    learn_rate,
    p
  )
  combine_result <- rbind(
    rst_gd, 
    rst_sgd, 
    rst_gd_m,
    rst_sgd_m
  )
  p <- ggplot(combine_result, aes(x=round,y = cost,color = type))
  p <- p + geom_line(size=1)
  p <- p + scale_y_continuous(limits = c(0, quantile(combine_result$cost,probs=0.9,na.rm=T)*1.2))
  p <- p + ggtitle(title)
  p
  
  list(p=p, stat = combine_result)
}


# Case 1 : 申请数据
appData <- read.csv("http://www.ats.ucla.edu/stat/data/binary.csv")
set.seed(4543615)
set.seed(12345)
logistic_regression_experiment(
  my_x = t(as.matrix(cbind(1,appData[,2:4]))),
  my_y = appData[,'admit'],
  max_iter = 100,
  learn_rate = 5e-5,
  p = 0.15,
  message = 'Data Apply'
)



# Case 2: 汽车数据 
set.seed(4543615) # 波动很大
# set.seed(4576768) # 非常明显
logistic_regression_experiment(
  my_x =  t(as.matrix(cbind(1,mtcars[,c(1:8,10:11)]))),
  my_y = mtcars[,'am'],
  max_iter = 1000,
  learn_rate = 1.4e-4,
  p = 0.45,
  message = 'Data mtcars'
)


rst[['p']]
head(rst[['stat']])

stat <- rst[['stat']]
head(stat[stat$type == 'sgd_m',])

# Case 3: iris数据
set.seed(3354) # 
logistic_regression_experiment(
  my_x = t(as.matrix(cbind(1,iris[,1:4]))),
  my_y = ifelse(iris$Species == 'setosa',1,0),
  max_iter = 5500,
  learn_rate = 1.4e-4,
  p = 0.15,
  message = 'Data iris'
)


