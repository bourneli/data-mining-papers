library(gbm)
require(mlbench)  # 里面有很多数据，可以使用验证模型
source('common_functions.R')


 
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
            interaction.depth=4,         # 1: additive model, 2: two-way interactions, etc.
            bag.fraction = 1,            # subsampling fraction, 0.5 is probably best
            train.fraction = 1,          # fraction of data for training,
            # first train.fraction*N used for training
            n.minobsinnode = 10,         # minimum total weight needed in each node
            keep.data=TRUE,              # keep a copy of the dataset with the object
            verbose=TRUE)  



## 测试单行
x <- iris[55,c(1:3,5)]
x
pretty.gbm.tree(gbm3,1)
gbdt_encode_one(gbm3,1,x) # ok
rst <- gbdt_encode(gbm3,x)
rst

 
## 多行测试
my_rst <- gbdt_encode(gbm3,iris[,c(1:3,5)])
dim(my_rst)
head(my_rst)
summary(my_rst)


