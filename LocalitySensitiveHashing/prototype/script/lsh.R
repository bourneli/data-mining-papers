taste <- read.csv('../data/lsh_sample_data.csv')

lsh_data <- taste 
lsh_data$id <- with(lsh_data, paste(app,open_id,sep="-"))
lsh_data$open_id <- NULL
lsh_data$app <- NULL
lsh_data$statis_date <- NULL
lsh_data <- lsh_data[,c(16,1:15)]
rm(taste)

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
  rst <- floor(rst/ bucket_width)
  
  rst
}

# 批量查询
lsh_batch_query <- function(lsh_table,id,k=5,l=10) {
  prime <- 2^32-5
  data_size <- nrow(lsh_table)
 
  # h1和h2构成的矩阵
  query_hash <- matrix(round(runif(2*k,-2^32,2^32),0), nrow = k)
  
  # 分词l分进行矩阵相乘
  rst <- data.frame()
  for(i in 1:l) {
    begin_col <- (i-1)*k+1
    end_col <- i*k
    
    current_rst <- lsh_table[,begin_col:end_col] %*% query_hash
    current_rst <- as.data.frame(current_rst)
    names(current_rst) <- c('h1','h2')
    current_rst$batch <- i
    current_rst$id <- id
    rst <- rbind(rst, current_rst)
  }
  
  rst
}

# 试验
set.seed(567)
bucket_width <- 0.5
k <- 10
l <- 50
sample_size <- 2000
data_index <- sample(1:nrow(lsh_data),sample_size)

feature <- lsh_data[data_index,2:16]
fm <- as.matrix(feature)


fm_lsh_table <- lsh_table(fm,bucket_width,k,l)
head(fm_lsh_table)
summary(fm_lsh_table)

fm_query <- lsh_batch_query(fm_lsh_table,lsh_data[data_index,1],k ,l)
head(fm_query)

require(plyr)
nn <- ddply(fm_query, .(batch,h1,h2), function(x) c(count=length(unique(x$id))))
summary(nn)




## 合并结果
nn_comb <- ddply(fm_query, .(batch,h1,h2), 
                 function(x) c(ids = paste(unique(x$id),collapse = ","),
                               count = length(unique(x$id))))
nn_comb_f <- nn_comb[nn_comb$count>1,]
head(nn_comb_f)

all_pairs <- lapply(nn_comb_f$ids, function(x) {
  a <- unlist(strsplit(x,','))
  c2 <-  t(combn(a,2))
  rbind(c2, c2[,2:1])
})

all_pairs <- Reduce(rbind, all_pairs)
all_pairs <- as.data.frame(all_pairs)
dim(all_pairs)
names(all_pairs) <- c('src','dst')
all_pairs2 <- unique(all_pairs)
dim(all_pairs2)

join1 <- merge(all_pairs2, lsh_data[data_index,],by.x='src',by.y='id')
join2 <- merge(join1, lsh_data[data_index,], by.x='dst',by.y = 'id')



nn_filter <- nn[nn$count > 1,]
summary(nn_filter)
nn_filter[which.max(nn_filter$count),]

sid <- fm_query[fm_query$h1==6509926930 & fm_query$h2==-744409678,
                c('batch','id')]
nrow(sid)

lsh_sample <- lsh_data[lsh_data$id %in% sid$id,2:7]
summary(lsh_sample)
summary( lsh_data[sample(1:nrow(lsh_data),300),2:7])


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


# # 测试dlply
# 
# d <- data.frame(h1=c(1,2,1,2,1),
#            h2=c(1,1,1,1,1),
#            id=1:5)
# d2 <- ddply(d,.(h1,h2), function(x) paste(x$id,collapse = ','))[,3]
# 
# sapply(d2, function(x) strsplit(x,',')[[1]])
# 
# 
# for(a in d2) {
#   print(a)
#   
#   ids <- strsplit(a,',')[[1]]
#   cb <- t(combn(ids,2))
#   cb <- rbind(cb, cb[,2:1])
#   cb <- as.data.frame(cb) 
# }
# 
# nl <- lapply(d2, function(x) unlist(strsplit(x,',')))
# nl
# 
# 
# nl2 <- lapply(d2, function(x) {
#   a <- unlist(strsplit(x,','))
#   c2 <-  t(combn(a,2))
#   rbind(c2, c2[,2:1])
#   
# })
# nl2
# 
# 
# Reduce(rbind,nl2)



L_bound <- function(theata, p, k = 10) {
  log(1-theata) /log(1-p^k)
}


t1<-0.95
p1 <- 1/2

L_bound(t1,p1)

t2<-0.15
p2 <- 1/3
L_bound(t2,p2)


# 欧式概率

root_fun <- function(target) {
  function(c) {
    1-2*pnorm(-1/c) + (2*c/sqrt(2*pi))*(exp(-1/(2*c^2))-1) - target
  }
  
}
root_fun_9 <- root_fun(0.9)

pr <-  root_fun(0)

x <- seq(0,10,by=0.01)
d <- data.frame(x=x,y=sapply(x,pr))

require(ggplot2)
text_size <- element_text(size = 19)
p <- qplot(x,100*y,data=d, geom="line") + xlab("C") + ylab("概率%") + ggtitle("") 
p <- p + scale_x_continuous(breaks=0:10)
p <- p + scale_y_continuous(breaks=seq(0,100,by=10))
p <- p + theme(axis.text = text_size,  axis.title = text_size)
p


# 数值解
root9 <- uniroot(root_fun_9, lower = 0.001, upper = 10)
pr(root9$root)

r1 <- sqrt(2)*0.05
r2 <- sqrt(2)*0.7

p1 <- 0.75
#p2 <- 0.1
p2 <-  0.1

g_i <- function(p) {
  uniroot(root_fun(p),lower = 1e-10, upper = 10, tol = 1e-5)$root
}

r1 / g_i(p1)
r2 / g_i(p2)

w <- (r1 / g_i(p1) + r2 / g_i(p2))/2
w



k <- 10

rho1 <- 0.99
rho2 <- 0.1

log(1-rho1) / log(1-p1^k)
log(1-rho2) / log(1-p2^k)



