收集大规模梯度下降优化的相关资料，主要参考目录是这篇博客[An overview of gradient descent optimization algorithms](http://sebastianruder.com/optimizing-gradient-descent/index.html)。根据这篇文章，大规模梯度下降优化主要有两个方向：1）学习率自适应；2）下降路径优化。

sgd Momentum 不稳定，但是好的时候，收敛速度比gd还快。

Nesterov accelerated gradient的论文无法搜索到，先看看Momentum的论文。


## (1999)On the momentum term in gradient descent learning algorithms

此文章从物理学能量的角度分析了为什么动量可以加快收敛。

公式（9）到公式（10）的变化是对公式（4）的右边左[泰勒展开](https://zh.wikipedia.org/wiki/%E6%B3%B0%E5%8B%92%E7%BA%A7%E6%95%B0)，然后在最小的地方$w_0$进行[线性估算](http://physics.stackexchange.com/a/133003)。为什会出现二次函数，因为 $\nabla_w E(W)=\frac{\partial E(w)}{\partial w}$ 。

公式（31）到公式（34）的变化，仍然是通过泰勒公式的线性估算展开，在 $\epsilon=0$附近的线性估算。

$\lambda_1$关于 $\epsilon$ 的一阶导数以及在 $\epsilon=0$处的值

$$
  \lambda_1^{(1)}(\epsilon)=-\frac{k_i}{2}-\frac{k_i}{2}(1+p-\epsilon k_i)\left((1+p-\epsilon k_i)^2-4p\right)^{-\frac{1}{2}}
  \\ \Rightarrow \lambda_1^{(1)}(0)=-\frac{k_i}{1-p}
$$

所以，可以得到 $\lambda_1^{(1)}$ 在 $\epsilon$ 很小时的线性估算

$$
  \lambda_1(\epsilon)\approx \lambda_1(0) + \lambda_1^{(1)}(0)\epsilon = 1 - \frac{\epsilon k_i}{1-p}
$$


同理，得到
$$
  \lambda_2( \epsilon ) \approx \lambda_2(0) + \lambda_2^{(1)}(0)\epsilon = p(1+\frac{k_i\epsilon}{1-p})
$$



通过上面两个泰勒公式的运用，好像一旦论文提到**expand**，均是泰勒展开，知乎上有一个[泰勒展开](https://www.zhihu.com/question/21149770)的讨论非常直观。


论文最后讨论p与收敛关系时，直接给出 $\lambda_1 = \lambda_2$时，收敛最优，但是没有给出原因。根据分析，可能需要使用隐函数。计算p与收敛时间t的关系，得到p等于什么的时候，有最小的t。形式简述如下

$$
  C_1 \bullet f(p)^t + C_2 \bullet g(p)^t - \epsilon = 0
$$

其中$C_1>0,C_2>0,\epsilon -> 0$为常量，$0<f(p)<1,0<g(p)<1$ 为已知处处可导函数。


### Result 1证明：连续空间，动量加速收敛条件

分情况证明：

  * 复数，可得到 $\frac{\mu^2}{4m} k_i < \frac{\mu^2}{2m}$
  * 非复数
    * 正数 不可能为正数
    * 负数 可得到 $k_i \le \frac{\mu^2}{4m}$

千万不要直接平方证明，多项式太复杂

### Result 2证明：比例变化

转成一个 $\alpha$关于 $k_i$的函数
