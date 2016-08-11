# Power方法估算最大特征值和特征向量
# 假设条件有点多

A <- matrix(c(-1,2,2,
              -1,-4,-2,
              -3,9,7),byrow = T,nrow=3)
A

set.seed(12344)
v_0 <- matrix(rnorm(3))

k <- 100

# 估算特征值
v <- v_0
lambda <- matrix(rep(0,3))
for(i in 1:k) {
  pre_v <- v
  v <- A %*% v
  lambda <- v / pre_v
}
lambda

# 估算特征向量
u <- v_0
lambda <- matrix(rep(0,3))
for(i in 1:k) {
  u <- A %*% u
  u  <- u / norm(u, '2')
}
u











