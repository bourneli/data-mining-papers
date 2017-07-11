require(xgboost)
data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')
dtrain <- xgb.DMatrix(data = agaricus.train$data, label = agaricus.train$label)
dtest <- xgb.DMatrix(data = agaricus.test$data, label = agaricus.test$label)

param <- list(max_depth=2, eta=1, silent=1, objective='binary:logistic')
nround = 4

bst = xgb.train(params = param, data = dtrain, nrounds = nround, nthread = 2)

# Model accuracy without new features
accuracy.before <- sum((predict(bst, agaricus.test$data) >= 0.5) == agaricus.test$label) /
  length(agaricus.test$label)

# Convert previous features to one hot encoding
new.features.train <- xgb.create.features(model = bst, agaricus.train$data)
new.features.test <- xgb.create.features(model = bst, agaricus.test$data)

# learning with new features
new.dtrain <- xgb.DMatrix(data = new.features.train, label = agaricus.train$label)
new.dtest <- xgb.DMatrix(data = new.features.test, label = agaricus.test$label)
watchlist <- list(train = new.dtrain)
bst <- xgb.train(params = param, data = new.dtrain, nrounds = nround, nthread = 2)

# Model accuracy with new features
accuracy.after <- sum((predict(bst, new.dtest) >= 0.5) == agaricus.test$label) /
  length(agaricus.test$label)

# Here the accuracy was already good and is now perfect.
cat(paste("The accuracy was", accuracy.before, "before adding leaf features and it is now",
          accuracy.after, "!\n"))











data(Satellite)

dtrain <- xgb.DMatrix(data = as.matrix(Satellite[,1:36]), label = as.numeric(Satellite[,37] == 'red soil'))
param <- list(max_depth=3, eta=1, silent=1, objective='binary:logistic')
nround <- 4

bst <- xgb.train(params = param, data = dtrain, nrounds = nround, nthread = 2)
new_feature_train <- xgb.create.features(bst, as.matrix(Satellite[,1:36]))
head(new_feature_train)
dim(new_feature_train)
new_feature_train[1,]


train_data <-  Satellite[,1:36]
train_data$classes <- factor(ifelse(Satellite[,37] == 'red soil', 'rs','non_rs'))

require(caret)
xgb_grid <- expand.grid(
  nrounds = c(50),
  eta = c(0.05, 0.1) ,
  max_depth = c(1,2,3),
  gamma = c(1,2),               
  colsample_bytree =c(0.3,0.5,1),    
  min_child_weight = 1,
  subsample = c( .7)
)
my_fit <- trainControl(
  method = "repeatedcv",
  number = 3,
  repeats = 1,
  classProbs = T 
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

xgb_model$finalModel
 
new_feature_train2 <- xgb.create.features(xgb_model$finalModel, as.matrix(Satellite[,1:36]))
head(new_feature_train2)
dim(new_feature_train2)
new_feature_train2[1,]
xgb_model
