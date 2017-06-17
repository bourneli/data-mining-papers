lol <- read.csv('data/fm_lol_data.csv')
lol$statis_date <- NULL
lol$uin <- NULL
lol$article_id <- NULL

table(lol$tag)

lol_data <- lol[,-542]
lol_data_sparse <- Matrix(as.matrix(lol_data), sparse = TRUE)
lol_tag <- lol$tag

require(FactoRizationMachines)

set.seed(454667)
train_index <- sample(nrow(lol_data), 10000)

fm_model <- FM.train(
  lol_data_sparse[train_index,],
  lol_tag[train_index],
  factors = c(1, 10), 
  intercept = T, 
  iter = 10, 
  regular = 0.001, 
  stdev = 0.1
)

print(fm_model) 


test_data <- lol_data_sparse[-train_index,1:540]

test_result <- predict(fm_model, test_data)
test_label <- sapply(test_result, function(x) ifelse(x > 0.5, 1,0) )


cm <- table(test_label, lol_tag[-train_index])
cm['1','1'] / sum(cm['1',])
cm['1','1'] / sum(cm[,'1'])




## 安装libRM R库
# devtools::install_github("andland/libFMexe")
devtools::install_git('https://github.com/andland/libFMexe.git')
 
