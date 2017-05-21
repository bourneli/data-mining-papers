#####################################################
# 比较下面三种模型在不同数据集上的效果
# 1 LR
# 2 GBDT
# 3 GBDT + LR
# 猜想：
# 2最好，3次之，1最差  
#####################################################

require(mlbench)
require(caret)
require(MLmetrics)
library(ade4)  # one-hot-encoding for factor

###################################################################
# Satellite数据
###################################################################
data(Satellite)
summary(Satellite)
dim(Satellite)
my_data <- Satellite
my_labels <- c('cc','non_cc')
my_data$classes <- ifelse(my_data$classes == 'cotton crop',1,0)
my_data$classes <- factor(
  my_data$classes,
  levels = 1:0,
  labels = my_labels
)
summary(my_data$classes)
result_file <- "data/result_satellite.csv"


####################################################################
# 元音辨认数据
####################################################################
data(Vowel)
my_data <- Vowel
f_v1_encode <- acm.disjonctif(my_data['V1'])
my_data$V1 <- NULL
my_data <- cbind(f_v1_encode, my_data)
my_labels <- c('pos', 'neg')
my_data$classes <- ifelse(Vowel$Class == 'hid', 1, 0)
my_data$Class <- NULL
my_data$classes <- factor(
  my_data$classes,
  levels = 1:0,
  labels = my_labels
)
summary(my_data)
result_file <- "data/result_vowel.csv"

####################################################################
# 汽车轮廓数据
####################################################################
data(Vehicle)
my_data <- Vehicle 
my_labels <- c('pos', 'neg')
my_data$classes <- ifelse(my_data$Class == 'van', 1, 0)
my_data$Class <- NULL
my_data$classes <- factor(
  my_data$classes,
  levels = 1:0,
  labels = my_labels
)
summary(my_data)
result_file <- 'data/result_vehicle.csv'

####################################################################
# 声呐数据
####################################################################
data(Sonar)
my_data <- Sonar
my_labels <- c('pos', 'neg')
my_data$classes <- ifelse(my_data$Class == 'R', 1, 0)
my_data$Class <- NULL
my_data$classes <- factor(
  my_data$classes,
  levels = 1:0,
  labels = my_labels
)
summary(my_data)
result_file <- 'data/result_sonar.csv'

####################################################################
# 糖料病数据
####################################################################
data(PimaIndiansDiabetes)
my_data <- PimaIndiansDiabetes
my_labels <- c('pos', 'neg')
my_data$classes <- ifelse(my_data$diabetes != 'pos', 1, 0)
my_data$diabetes <- NULL
my_data$classes <- factor(
  my_data$classes,
  levels = 1:0,
  labels = my_labels
)
summary(my_data)
result_file <- 'data/result_diabetes.csv'




set.seed(680)
k <- 5
cv_index <- k_fold_index(nrow(my_data), k)
my_fit <- trainControl(
  method = "repeatedcv",
  number = 3,
  repeats = 1,
  classProbs = T 
)
result <- data.frame()
for(r in 1:k) {
  
  train_data <- my_data[cv_index != r,]
  test_data <- my_data[cv_index == r,]
  test_data_label <- ifelse(test_data$classes == my_labels[1], 1, 0)

  ###############################################
  # LR
  ###############################################
  lr_grid <- expand.grid(
    alpha = c(0,0.3,1),
    lambda = c(0.01,0.1,0.3)
  )
  lr_model <- train(
    classes~.,
    data = train_data,
    method = 'glmnet',
    trControl = my_fit,
    tuneGrid = lr_grid,
    #metric = 'Prec',
    metric = 'Accuracy',
    standardize = T
  )
  lr_pred <- predict(lr_model, test_data, type = 'raw')
  lr_pred_prob <- predict(lr_model, test_data, type = 'prob')

  # 计算指标
  current_result <- binaryMetric(
    positive_tag = my_labels[1],
    true_type = test_data$classes,
    pred_type = lr_pred,
    true_prob = test_data_label,
    pred_prob = lr_pred_prob
  )
  current_result <- cbind(
    data.frame(round=r, model = 'lr'),
    current_result
  )
  print(current_result)
  result <- rbind(result,current_result)
  
  ###############################################
  # GBDT
  ###############################################
  xgb_grid <- expand.grid(
    nrounds = c(50),
    eta = c(0.05, 0.1) ,
    max_depth = c(1,2,3),
    gamma = c(1,2),               
    colsample_bytree =c(0.3,0.5,1),    
    min_child_weight = 1,
    subsample = c( .7)
  )
  xgb_model <- train(
    classes ~ ., 
    data = train_data, 
    method = 'xgbTree',
    trControl = my_fit,
    tuneGrid = xgb_grid,
    verbose = F,
    #metric = 'Prec',
    metric = 'Accuracy',
    nthread = 4
  )
  xgb_pred <- predict(xgb_model, test_data, type = 'raw')
  xgb_pred_prob <- predict(xgb_model, test_data, type = 'prob') 
  
  # 计算指标
  current_result <- binaryMetric(
    positive_tag = my_labels[1],
    true_type = test_data$classes,
    pred_type = xgb_pred,
    true_prob = test_data_label,
    pred_prob = xgb_pred_prob
  )
  current_result <- cbind(
    data.frame(round=r, model = 'gbdt'), 
    current_result
  )
  print(current_result)
  result <- rbind(result,current_result)
  
  ###############################################
  # GBDT + LR
  ###############################################
  
  my_data_encode <- xgb.create.features(
    xgb_model$finalModel,
    as.matrix(my_data[,1:(ncol(my_data)-1)])
  )
  my_data_encode <- as.data.frame(as.matrix(my_data_encode)) 
  # 新特征名称可能存在重复，需要重命名
  names(my_data_encode) <- paste("f",1:ncol(my_data_encode),sep='')
  
  my_data_encode$classes <- my_data$classes
  
  train_data_encode <- my_data_encode[cv_index != r,]
  test_data_encode <- my_data_encode[cv_index == r,]
  
  
  lr_model <- train(
    classes~.,
    data = train_data_encode,
    method = 'glmnet',
    trControl = my_fit,
    tuneGrid = lr_grid,
    #metric = 'Prec',
    metric = 'Accuracy',
    standardize = T
  )
  lr_pred <- predict(lr_model, test_data_encode, type = 'raw')
  lr_pred_prob <- predict(lr_model, test_data_encode, type = 'prob')

  # 计算指标
  current_result <- binaryMetric(
    positive_tag = my_labels[1],
    true_type = test_data$classes,
    pred_type = lr_pred,
    true_prob = test_data_label,
    pred_prob = lr_pred_prob
  )
  current_result <- cbind(
    data.frame(round=r, model = 'gbdt + lr'),
    current_result
  )
  print(current_result)
  result <- rbind(result,current_result)
  
  ###############################################
  # GBDT + GBDT
  ###############################################
  xgb_model2 <- train(
    classes ~ ., 
    data = train_data_encode, 
    method = 'xgbTree',
    trControl = my_fit,
    tuneGrid = xgb_grid,
    verbose = F,
    #metric = 'Prec',
    metric = 'Accuracy',
    nthread = 4
  )
  xgb_pred <- predict(xgb_model2, test_data_encode, type = 'raw')
  xgb_pred_prob <- predict(xgb_model2, test_data_encode, type = 'prob') 
  
  # 计算指标
  current_result <- binaryMetric(
    positive_tag = my_labels[1],
    true_type = test_data$classes,
    pred_type = xgb_pred,
    true_prob = test_data_label,
    pred_prob = xgb_pred_prob
  )
  current_result <- cbind(
    data.frame(round=r, model = 'gbdt + gbdt'), 
    current_result
  )
  print(current_result)
  result <- rbind(result,current_result)
  
}

ddply(
  result,
  .(model),
  function(x) {
    c(
      precision = mean(x$precision),
      recall = mean(x$recall),
      auc = mean(x$auc),
      accuracy = mean(x$accuracy),
      f1 = mean(x$f1)
    )
  }
)

write.csv(result, file = result_file, quote=F, row.names = F)
 
 