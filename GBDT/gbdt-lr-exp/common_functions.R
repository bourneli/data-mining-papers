# 下面两个链接用于介绍gbm相关参数，非常有用
# https://stats.stackexchange.com/questions/5601/how-to-view-gbm-package-trees
# https://stats.stackexchange.com/questions/16501/what-does-interaction-depth-mean-in-gbm

###########################################################
# 根据gbdt一棵树的叶节点，编码特征x
# @param model gbm模型
# @param tree_index 数索引
# @param x 特征，顺序必须与模型一致
# @return 叶节点id，
###########################################################
gbdt_encode_one <- function(model, tree_index, x) {
  require(gbm)  
  
  pretty_model <- pretty.gbm.tree(model, tree_index)
  
  ####################################
  # target_node 节点索引，从0开始
  ####################################
  go_into_target_node <- function(target_node) {
    target_node_index <- target_node + 1
    split_index <- pretty_model[target_node_index, 'SplitVar']
    value_index <- split_index + 1
    split_value <- pretty_model[target_node_index, 'SplitCodePred'] # 切分值
    target_value <- x[1, value_index]  # x中的判断值
    
    if (-1 == split_index) {
      target_node 
    } else {
      target_node <- if (is.na(x[1, split_index+1])) {
        pretty_model[target_node_index, 'MissingNode']
      }
      else if (is.numeric(target_value) 
               && target_value <= split_value) {
        pretty_model[target_node_index, 'LeftNode']
      } 
      else if (is.factor(target_value) 
               && (which(levels(target_value) == target_value) - 1) == split_value){
        pretty_model[target_node_index, 'LeftNode']
      } else {
        pretty_model[target_node_index, 'RightNode']
      }
      
      go_into_target_node(target_node)
    }
  }
  go_into_target_node(0)
}

###########################################################
# 根据gbdt模型，需要编码特征x
# @param model gbm模型
# @param x 特征，顺序必须与模型一致
# @return 编码特征
###########################################################
gbdt_encode <- function(model, x) {
  
  require(plyr)
  
  adply(x, 1, function(x) {
    rst <- sapply(1:model$n.trees, function(i) {
      this_code <- gbdt_encode_one(model, i, x)
      
      tree_struct <- pretty.gbm.tree(model, i)
      all_leaf_code <- row.names(subset(tree_struct,tree_struct$SplitVar == -1))
      as.numeric(all_leaf_code == this_code)    
    })
    
    rst <-as.vector(rst)
    names(rst) <- paste("gbdt_node_", 1:length(rst),sep='')
    rst
    
  })
}

###########################################################
# 生成k fold交叉验证的索引
# n 总样本量
# k 交叉数量
###########################################################
k_fold_index <- function(n, k = 5) {
  index <- rep(1:k, length.out = n)
  sample(index, length(index), replace = FALSE)
} 


# 二元分类指标计算
binaryMetric <- function(
  positive_tag,
  true_type,
  pred_type,
  true_prob,
  pred_prob
){
  prec <- Precision(
    y_pred = pred_type,
    y_true = true_type, 
    positive = positive_tag
  )
  recall <- Recall(
    y_pred = pred_type,
    y_true = true_type, 
    positive = positive_tag
  )
  auc <- AUC(
    y_pred = pred_prob[, positive_tag],
    y_true = true_prob
  )
  f1 <- F1_Score(
    y_pred = pred_type,
    y_true = true_type,
    positive = positive_tag
  )
  accuracy <- Accuracy(y_pred = pred_type, y_true = true_type)
  
  # 记录结果
  data.frame(
    precision = prec,
    recall = recall,
    auc = auc,
    f1 = f1,
    accuracy = accuracy
  )
}

