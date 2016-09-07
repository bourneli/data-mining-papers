taste <- read.csv('../data/lsh_sample_data.csv')

lsh_data <- taste 
lsh_data$id <- with(lsh_data, paste(app,open_id,sep="-"))
lsh_data$open_id <- NULL
lsh_data$app <- NULL
lsh_data$statis_date <- NULL
lsh_data <- lsh_data[,c(16,1:15)]
rm(taste)

feature <- lsh_data[,2:16]
fm <- as.matrix(feature)

# feature必须是matrix
lsh_table <- function(feature, bucket_width, k=5, l = 10) {
  # 数据维度
  vector_width <- ncol(feature)
  data_length <- nrow(feature)
  
  # 生成lsh参数
  hash_matrix <- matrix(rnorm(vector_width*k*l), nrow=vector_width)
  offset <- matrix(runif(k*l,min=0,max=bucket_width), nrow = 1)

  
  # 计算lsh
  rst <- feature %*% hash_matrix 
  rst <- rst + matrix(rep(1,data_length),nrow=data_length) %*% offset
  rst <- floor(rst)
  
  rst
}



# 批量查询
lsh_batch_query <- function(lsh_table,id,k=5,l=10) {
  prime <- 2^32-5
  data_size <- nrow(lsh_table)
 
  # h1和h2构成的矩阵
  query_hash <- matrix(round(runif(2*k,0,2^32),0), nrow = k)
  
  # 分词l分进行矩阵相乘
  rst <- data.frame()
  for(i in 1:l) {
    begin_col <- (i-1)*k+1
    end_col <- i*k
    
    current_rst <- lsh_table[,begin_col:end_col] %*% query_hash
    current_rst <- as.data.frame(current_rst)
    names(current_rst) <- c('h1','h2')
    current_rst$id <- id
    rst <- rbind(rst, current_rst)
  }
  
  rst
}

# 试验
set.seed(1123324)
bucket_width <- 1e-5
k <- 10
l <- 20


fm_lsh_table <- lsh_table(fm,bucket_width,k,l)
head(fm_lsh_table)
summary(fm_lsh_table)

fm_query <- lsh_batch_query(fm_lsh_table,lsh_data[,1],k ,l)
head(fm_query)


require(plyr)
nn <- ddply(fm_query, .(h1,h2), function(x) c(count=length(unique(x$id))))
summary(nn)

nn_filter <- nn[nn$count > 1,]
summary(nn_filter)
# sid <- fm_query[fm_query$h1=='-1036557670'&fm_query$h2=='-7703609579','id']
# summary(lsh_data[lsh_data$id %in% sid,2:7])
# summary( lsh_data[,2:7] )


sum(sapply(nn_filter$count, function(x) choose(x,2)*2)) / nrow(lsh_data)^2

head(nn)
require(ggplot2)
qplot(count, data = nn, geom='histogram')


nn_list <- dlply

a <- c('a','b','c')

for(e in a) {
  other <- a[a!=e]
  for(o in other){
    pair <- c(e,o)
    print(pair)
  }
}




