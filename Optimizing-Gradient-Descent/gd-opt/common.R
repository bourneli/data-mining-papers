


############################################################
# 线性回归梯度(批量)
# x 输入，列为特征，共n列，m个特征（包括截距）
# y 列向量
# w 权重，包括截距
############################################################
linear_regression_gradient_batch <- function(x,y,w) {
  (x %*% t(x) %*% w - x %*% y)/length(y)
}


############################################################
# 线性回归梯度(单独一个，适用于SGD)
# x 输入，列为特征，共n列，m个特征（包括截距）
# y 列向量
# w 权重，包括截距
# i 第几个x
############################################################
linear_regression_gradient_single <- function(x,y,w,i) {
  x_i <- x[,i]
  delta_y_i <- t(x_i) %*% w - y[i]
  x_i*delta_y_i
}


############################################################
# 线性回归开销函数
# x 输入，列为特征，共n列，m个特征（包括截距）
# y 列向量
# w 权重，包括截距
############################################################
linear_regression_cost <- function(x,y,w) {
  col_cost <- t(x) %*% w - y
  1/2 * t(col_cost) %*% col_cost
}

############################################################
# 逻辑规划开销函数
# x 输入，列为特征，共n列，m个特征（包括截距）
# y 列向量
# w 权重，包括截距
############################################################
logistic_regression_cost <- function(x,y,w) {
  pred <- 1/(1+exp(-1 * t(x) %*% w))
  col_cost <- -(y*log(pred) + (1-y)*log(1-pred))
  t(col_cost) %*% col_cost 
}

############################################################
# 逻辑回归梯度（单独一个，适合SGD）
# 参考： https://math.stackexchange.com/questions/477207/derivative-of-cost-function-for-logistic-regression
# x 输入，列为特征，共n列，m个特征（包括截距）
# y 列向量
# w 权重，包括截距
# i 第几个x
############################################################
logistic_regression_gradient_single <- function(x,y,w,i) {
  x_i <- x[,i]
  pred <- 1 / (1 + exp(-t(x_i) %*% w))
  delta_y_i <- pred - y[i]
  x_i * delta_y_i
}

############################################################
# 逻辑回归梯度
# 参考： https://math.stackexchange.com/questions/477207/derivative-of-cost-function-for-logistic-regression
# x 输入，列为特征，共n列，m个特征（包括截距）
# y 列向量
# w 权重，包括截距
############################################################
logistic_regression_gradient_batch <- function(x,y,w,i) {

  pred <- 1 / (1 + exp(-t(x) %*% w))
  delta_y <- pred - y
  
  x %*% delta_y / length(y)
}


############################################################
# 梯度递减
# graidnet_fun 梯度计算函数
# cost_fun 开销计算函数
############################################################
gd <- function(gradient_fun, cost_fun) {
  function(x,y,w, alpha, maxIter = 1000) {
    
    rst <- data.frame()
    for(r in 1:maxIter) {
      w <- w - alpha * gradient_fun(x,y,w)
      current_cost <- cost_fun(x,y,w)
      
      current_result <- data.frame(
        round = r, 
        cost = current_cost, 
        type = 'gd'
      )
      print(current_result)
      rst <- rbind(rst, current_result)
    }
    print(w)
    rst
  }
}


############################################################
# 随机梯度递减
# graidnet_fun 梯度计算函数
# cost_fun 开销计算函数
############################################################
sgd <- function(gradient_fun, cost_fun) {
  function(x,y,w, alpha, maxIter = 1000) {
    
    rst <- data.frame()
    for(r in 1:maxIter) {
      
      i <- sample(ncol(x),1)
      w <- w - alpha * gradient_fun(x,y,w,i)
      current_cost <- cost_fun(x,y,w)
      
      current_result <- data.frame(
        round = r, 
        cost = current_cost,
        type = 'sgd'
      )
      print(current_result)
      rst <- rbind(rst, current_result)
    }
    print(w)
    rst
  }
}

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
      
      current_result <- data.frame(
        round = r, 
        cost = current_cost,
        type = 'gd_m'
      )
      print(current_result)
      rst <- rbind(rst, current_result)
    }
    print(w)
    rst
  }
}


############################################################
# 动量随机梯度递减
# graidnet_fun 梯度计算函数
# cost_fun 开销计算函数
############################################################
sgd_momentum <- function(gradient_fun, cost_fun) {
  function(x,y,w, alpha,p=0.9, max_iter = 1000) {
    
    v <- w
    rst <- data.frame()
    for(r in 1:max_iter) {
      
      i <- sample(length(w),1)
      v <- p*v + alpha * gradient_fun(x,y,w,i)
      w <- w - v
      current_cost <- cost_fun(x,y,w)
      
      current_result <- data.frame(
        round = r, 
        cost = current_cost,
        type = 'sgd_m'
      )
      print(current_result)
      rst <- rbind(rst, current_result)
    }
    print(w)
    rst
  }
}

############################################################
# 动量随机梯度递减优化算法
# graidnet_fun 梯度计算函数
# cost_fun 开销计算函数
############################################################
sgd_nag <- function(gradient_fun, cost_fun) {
  function(x,y,w, alpha,p=0.9, max_iter = 1000) {
    
    v <- w
    rst <- data.frame()
    for(r in 1:max_iter) {
      
      i <- sample(length(w),1)
      v <- p*v + alpha * gradient_fun(x,y,w-p*v,i)
      w <- w - v
      current_cost <- cost_fun(x,y,w)
      
      current_result <- data.frame(
        round = r, 
        cost = current_cost,
        type = 'sgd_nag'
      )
      print(current_result)
      rst <- rbind(rst, current_result)
    }
    print(w)
    rst
  }
}


