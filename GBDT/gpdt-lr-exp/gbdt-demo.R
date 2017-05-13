library(gbm)
require(mlbench)
data(PimaIndiansDiabetes2,package='mlbench')
# 将响应变量转为0-1格式
data <- PimaIndiansDiabetes2
data$diabetes <- as.numeric(data$diabetes)
data$cate <- as.factor(data$diabetes)
data <- transform(data,diabetes=diabetes-1)
# 使用gbm函数建模
model <- gbm(diabetes~.,data=data,shrinkage=0.001,
             distribution='bernoulli',cv.folds=5,
             n.trees=30,verbose=F,
             interaction.depth=3)

best.iter <- gbm.perf(model,method='cv')

pretty.gbm.tree(model, i.tree = 11)

tree_size <- sapply(
  1:30, 
  function(x) nrow(pretty.gbm.tree(model, i.tree = x))
)

model$trees[[11]]

pretty.gbm.tree(model, i.tree = 30)
model$c.splits
pretty.gbm.tree(model, i.tree = 3000)['0',]


# https://stats.stackexchange.com/questions/5601/how-to-view-gbm-package-trees
# https://stats.stackexchange.com/questions/16501/what-does-interaction-depth-mean-in-gbm
set.seed(1973)

############## CREATE DATA#############################################
N <- 1000
X1 <- runif(N)
X2 <- 2*runif(N)
X3 <- ordered(sample(letters[1:4],N,replace=TRUE),levels=letters[4:1])
X4 <- factor(sample(letters[1:6],N,replace=TRUE))
X5 <- factor(sample(letters[1:3],N,replace=TRUE))
X6 <- 3*runif(N)
mu <- c(-1,0,1,2)[as.numeric(X3)]

SNR <- 10 # signal-to-noise ratio
Y <- X1**1.5 + 2 * (X2**.5) + mu
sigma <- sqrt(var(Y)/SNR)
Y <- Y + rnorm(N,0,sigma)

# introduce some missing values
X1[sample(1:N,size=500)] <- NA
X4[sample(1:N,size=300)] <- NA

data <- data.frame(Y=Y,X1=X1,X2=X2,X3=X3,X4=X4,X5=X5,X6=X6)
########################################################################

#Fit model##############################################################
gbm1 <- gbm(Y~X1+X2+X3+X4+X5+X6, # formula
            data=data,                   # dataset
            var.monotone=c(0,0,0,0,0,0), # -1: monotone decrease,
            # +1: monotone increase,
            #  0: no monotone restrictions
            distribution="gaussian",     # bernoulli, adaboost, gaussian,
            # poisson, coxph, and quantile available
            n.trees=10,                   # number of trees
            shrinkage=1,                 # shrinkage or learning rate,
            # 0.001 to 0.1 usually work
            interaction.depth=3,         # 1: additive model, 2: two-way interactions, etc.
            bag.fraction = 1,            # subsampling fraction, 0.5 is probably best
            train.fraction = 1,          # fraction of data for training,
            # first train.fraction*N used for training
            n.minobsinnode = 10,         # minimum total weight needed in each node
            keep.data=TRUE,              # keep a copy of the dataset with the object
            verbose=TRUE)                # print out progress

###########################################################################


pretty.gbm.tree(gbm1,i.tree = 1)



gbm2 <- gbm(Species~., # formula
            data=iris,                   # dataset
            var.monotone=c(0,0,0,0), # -1: monotone decrease,
            # +1: monotone increase,
            #  0: no monotone restrictions
            distribution="gaussian",     # bernoulli, adaboost, gaussian,
            # poisson, coxph, and quantile available
            n.trees=10,                   # number of trees
            shrinkage=1,                 # shrinkage or learning rate,
            # 0.001 to 0.1 usually work
            interaction.depth=3,         # 1: additive model, 2: two-way interactions, etc.
            bag.fraction = 1,            # subsampling fraction, 0.5 is probably best
            train.fraction = 1,          # fraction of data for training,
            # first train.fraction*N used for training
            n.minobsinnode = 10,         # minimum total weight needed in each node
            keep.data=TRUE,              # keep a copy of the dataset with the object
            verbose=TRUE)  


pretty.gbm.tree(gbm2,1)

###################################################
# x索引需要和变量保持一致,暂时不支持category版本
###################################################
gbdt_encode_one <- function(model, tree_index, x) {
  
  
  pretty_model <- pretty.gbm.tree(model, tree_index)
  
  ####################################
  # target_node 节点索引，从0开始
  ####################################
  go_into_target_node <- function(target_node) {
    target_node_index <- target_node + 1
    split_index <- pretty_model[target_node_index, 'SplitVar']
    value_index <- split_index + 1
    split_value <- pretty_model[target_node_index, 'SplitCodePred']
    
    if (-1 == split_index) {
      target_node 
    } else {
      target_node <- if (is.na(x[1, split_index+1])) {
        pretty_model[target_node_index, 'MissingNode']
      } else if (x[1, value_index] <= split_value) {
        pretty_model[target_node_index, 'LeftNode']
      } else {
        pretty_model[target_node_index, 'RightNode']
      }
      go_into_target_node(target_node)
    }
  }
  
  
  go_into_target_node(0)
  
  
}



iris[1,1:4]

pretty.gbm.tree(gbm2,1)
gbdt_encode_one(gbm2,1,iris[1,1:4])  # ok

pretty.gbm.tree(gbm2,2)
gbdt_encode_one(gbm2,2,iris[1,1:4]) # ok

pretty.gbm.tree(gbm2,3)
gbdt_encode_one(gbm2,3,iris[1,1:4]) # ok

pretty.gbm.tree(gbm2,4)
gbdt_encode_one(gbm2,4,iris[1,1:4]) # ok

iris[91, 1:4]
pretty.gbm.tree(gbm2,5)
gbdt_encode_one(gbm2,5,iris[91,1:4]) # ok


iris[55, 1:4]
pretty.gbm.tree(gbm2,6)
gbdt_encode_one(gbm2,6,iris[55,1:4]) # ok




gbm3 <- gbm(Petal.Width~., # formula
            data=iris,                   # dataset
            var.monotone=c(0,0,0,0), # -1: monotone decrease,
            # +1: monotone increase,
            #  0: no monotone restrictions
            distribution="gaussian",     # bernoulli, adaboost, gaussian,
            # poisson, coxph, and quantile available
            n.trees=10,                   # number of trees
            shrinkage=1,                 # shrinkage or learning rate,
            # 0.001 to 0.1 usually work
            interaction.depth=3,         # 1: additive model, 2: two-way interactions, etc.
            bag.fraction = 1,            # subsampling fraction, 0.5 is probably best
            train.fraction = 1,          # fraction of data for training,
            # first train.fraction*N used for training
            n.minobsinnode = 10,         # minimum total weight needed in each node
            keep.data=TRUE,              # keep a copy of the dataset with the object
            verbose=TRUE)  

pretty.gbm.tree(gbm3,1)
pretty.gbm.tree(gbm3,2)
pretty.gbm.tree(gbm3,3)
pretty.gbm.tree(gbm3,4)
pretty.gbm.tree(gbm3,5)
pretty.gbm.tree(gbm3,6)
pretty.gbm.tree(gbm3,7)
pretty.gbm.tree(gbm3,8)
pretty.gbm.tree(gbm3,9)
pretty.gbm.tree(gbm3,10)

# 通过levels可以得到category的编码顺序

f <- factor(c('b','b','a','c','b','c'))
levels(f)

f1 <- factor(f,
             levels = c('c','a','b'),
             labels = c('C','A','B'))


f2 <- factor(f,
             levels = c('c','a','b'),
             labels = c('c','a','b'))
f2
