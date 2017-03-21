############################################################
# 尝试SGD在线性规划上的收敛效果
############################################################


fit  <- lm(Petal.Width ~ Sepal.Length + Sepal.Width + Petal.Length, data = iris)
summary(fit)


############################################################
# 梯度
# x 输入，列为特征，共n列，m个特征（包括截距）
# y 列向量
# w 权重，包括截距
############################################################
gradient <- function(x,y,w) {
  x %*% t(x) %*% w - x %*% y
}

############################################################
# 开销函数
# x 输入，列为特征，共n列，m个特征（包括截距）
# y 列向量
# w 权重，包括截距
############################################################
cost <- function(x,y,w) {
  col_cost <- t(x) %*% w - y
  1/2 * t(col_cost) %*% col_cost
}

############################################################
# 梯度递减
# graidnet_fun 梯度计算函数
# cost_fun 开销计算函数
############################################################
gd <- function(gradient_fun, cost_fun) {
  function(x,y,w, alpha, maxIter = 1000) {
    
    rst <- data.frame()
    for(i in 1:maxIter) {
      w <- w - alpha * gradient_fun(x,y,w)
      current_cost <- cost_fun(x,y,w)
      
      current_result <- data.frame(round = i, cost = current_cost)
      print(current_result)
      rst <- rbind(rst, current_result)
    }
    print(w)
    rst
  }
}




# my_x <- t(as.matrix(cbind(iris[,1:3],1)))
# my_y <- as.matrix(iris[,4])
# set.seed(1234)
# my_w <- as.matrix(rnorm(4))
# 
# cost(my_x, my_y, my_w)
# gradient(my_x,my_y,my_w)
max_iter <- 5000



my_gd <- gd(gradient, cost)
rst_gd <- my_gd(my_x,my_y,my_w,0.0001, max_iter)
rst_gd$type <- 'gd'
require(ggplot2)
qplot(x=round, y = cost,data = rst_gd, geom = 'line' )
summary(rst_gd)

# 标准的lm
lm(Petal.Width ~ Sepal.Length + Sepal.Width + Petal.Length, data = iris)

############################################################
# 随机梯度递减
# graidnet_fun 梯度计算函数
# cost_fun 开销计算函数
############################################################
sgd <- function(gradient_fun, cost_fun) {
  function(x,y,w, alpha, maxIter = 1000) {
    
    
    rst <- data.frame()
    for(r in 1:maxIter) {
      
      i <- sample(length(w),1)
      w[i] <- w[i] - alpha * gradient_fun(x,y,w)[i] # 此处可以优化
      current_cost <- cost_fun(x,y,w)
      
      current_result <- data.frame(round = r, cost = current_cost)
      print(current_result)
      rst <- rbind(rst, current_result)
    }
    print(w)
    rst
  }
}

my_sgd <- sgd(gradient, cost)
rst_sgd <- my_sgd(my_x,my_y,my_w,0.0001, max_iter)
rst_sgd$type <- 'sgd'
qplot(x=round, y = cost,data = rst_sgd, geom = 'line' )
summary(rst_sgd)




############################################################
# 动量梯度递减
# graidnet_fun 梯度计算函数
# cost_fun 开销计算函数
############################################################
gd_momentum <- function(gradient_fun, cost_fun) {
  function(x,y,w, alpha,p=0.9, maxIter = 1000) {
    
    v <- w
    rst <- data.frame()
    for(r in 1:maxIter) {
      
      
      v <- p*v + alpha * gradient_fun(x,y,w)
      w <- w - v
      current_cost <- cost_fun(x,y,w)
      
      current_result <- data.frame(round = r, cost = current_cost)
      print(current_result)
      rst <- rbind(rst, current_result)
    }
    print(w)
    rst
  }
}

my_gd_m <- gd_momentum(gradient, cost)
rst_gd_m <- my_gd_m(my_x,my_y,my_w,0.0001,0.9, max_iter)
rst_gd_m$type <- 'gd_m'
qplot(x=round, y = cost,data = rst_gd_m, geom = 'line' )
summary(rst_gd_m)


############################################################
# 动量随机梯度递减
# graidnet_fun 梯度计算函数
# cost_fun 开销计算函数
############################################################
sgd_momentum <- function(gradient_fun, cost_fun) {
  function(x,y,w, alpha,p=0.9, maxIter = 1000) {
    
    v <- w
    rst <- data.frame()
    for(r in 1:maxIter) {
      
      i <- sample(length(w),1)
      v <- p*v
      v[i] <- alpha * gradient_fun(x,y,w)[i]
      w <- w - v
      current_cost <- cost_fun(x,y,w)
      
      current_result <- data.frame(round = r, cost = current_cost)
      print(current_result)
      rst <- rbind(rst, current_result)
    }
    print(w)
    rst
  }
}

my_sgd_m <- sgd_momentum(gradient, cost)
rst_sgd_m <- my_sgd_m(my_x,my_y,my_w,0.0001,0.9, max_iter)
rst_sgd_m$type <- 'sgd_m'
qplot(x=round, y = cost,data = rst_sgd_m, geom = 'line' )
summary(rst_sgd_m)

comp_rst <- rbind(rst_sgd,rst_gd_m,rst_gd,rst_sgd_m)
comp_rst <- subset(comp_rst, comp_rst$round > 2000)
p <- ggplot(comp_rst, aes(x=round,y = cost,color = type))
p <- p + geom_line()
p

