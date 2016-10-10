# 碰撞函数
root_fun <- function(target) {
  function(c) {
    1-2*pnorm(-1/c) + (2*c/sqrt(2*pi))*(exp(-1/(2*c^2))-1) - target
  }
  
}

# 碰撞函数反函数
g_i <- function(p) {
  uniroot(root_fun(p),lower = 1e-10, upper = 10, tol = 1e-5)$root
}


# max D = 10
# 设置w
r1 <- 0.01
r2 <- 1.3

p1 <- 0.97
p2 <-  0.1
#p2 <-  0.05

w1 <- r1 / g_i(p1)
w1
w2 <- r2 / g_i(p2)
w2


w <- r1 / g_i(p1) 
w

w <- r1 / g_i(p1) 
w <- r2 / g_i(p2)
      
c_1 <- r1/w
p_1 <- root_fun(0)(c_1)
p_1

c_2 <- r2/w
p_2 <- root_fun(0)(c_2)
p_2




# 设置L

k <- 10
rho1 <- 0.99
rho2 <- 0.01

log(1-rho1) / log(1-p1^k)
log(1-rho2) / log(1-p2^k)

L <- ceiling(log(1-rho1) / log(1-p1^k))
L

L <- 6

1-(1-p1^k)^L
1-(1-p2^k)^L


