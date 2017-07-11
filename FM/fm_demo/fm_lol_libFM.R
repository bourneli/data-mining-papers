library(e1071)
library(SparseM)

lol <- read.csv('data/fm_lol_data.csv')
lol$statis_date <- NULL
lol$uin <- NULL
lol$article_id <- NULL


tag_index <- ncol(lol)
lol_tag <- lol[,tag_index]
lol_tag <- sapply(lol_tag, function(x) ifelse(x > 0, 1.0, -1.0))
lol_data <- lol[,-tag_index]


# 正规化lol_data

col_max <- apply(lol_data,2,max)
col_min <- apply(lol_data,2,min)
col_range <- sapply(col_max - col_min, function(x) ifelse(x == 0, 1, x))
lol_data <- scale(lol_data, center = col_min, scale = col_range)
 

n <- nrow(lol_data)


set.seed(34676)
train_index <- sample(n, n*0.7)

# 训练数据
train_x <- lol_data[train_index,]
train_y <- lol_tag[train_index]
write.matrix.csr(
  x = as.matrix.csr(as.matrix(train_x)),
  y = train_y,
  file = 'data/train.libsvm',
  fac = F
)


# 重采样训练数据,调整正负样本比例
pos_data <- subset(lol[train_index,], lol[train_index,'tag'] == 1)

neg_sub_rate <- 0.15
set.seed(7899)
neg_data <- subset(lol[train_index,], lol[train_index,'tag'] == 0)
neg_index <- sample(nrow(neg_data), nrow(neg_data)*neg_sub_rate)
sub_neg_data <- neg_data[neg_index,]


resample_data <- rbind(pos_data, sub_neg_data)
resample_data <- resample_data[sample(nrow(resample_data)),]

train_x2 <- resample_data[,-tag_index]
train_y2 <- sapply(resample_data[, tag_index], function(x) ifelse(x > 0, 1, -1))


# train_x2归一化
col_max <- apply(train_x2,2,max)
col_min <- apply(train_x2,2,min)
col_range <- sapply(col_max - col_min, function(x) ifelse(x==0,1,x))
train_x2_norm <- scale(train_x2, center = col_min, scale = col_range)


write.matrix.csr(
  x = as.matrix.csr(as.matrix(train_x2_norm)),
  y = train_y2,
  file = 'data/train3.libsvm',
  fac = F
)






# 测试数据
test_x <- lol_data[-train_index,]
test_y <- lol_tag[-train_index]

write.matrix.csr(
  x = as.matrix.csr(as.matrix(test_x)),
  y = test_y,
  file = 'data/test3.libsvm',
  fac = F
)




library(pROC)
test <- read.table('data/predict.txt',header=F)
actual <- test_y

pred <- prediction(test, actual)
perf <- performance(pred, 'auc')
perf@y.values



 


