收集大规模梯度下降优化的相关资料，主要参考目录是这篇博客[An overview of gradient descent optimization algorithms](http://sebastianruder.com/optimizing-gradient-descent/index.html)。根据这篇文章，大规模梯度下降优化主要有两个方向：1）学习率自适应；2）下降路径优化。

sgd Momentum 不稳定，但是好的时候，收敛速度比gd还快。

Nesterov accelerated gradient的论文无法搜索到，先看看Momentum的论文。


## (1999)On the momentum term in gradient descent learning algorithms

此文章从物理学能量的角度分析了为什么动量可以加快收敛。

公式（9）到10的变化是对公式（4）的右边左[泰勒展开](https://zh.wikipedia.org/wiki/%E6%B3%B0%E5%8B%92%E7%BA%A7%E6%95%B0)，然后在最小的地方$w_0$进行[线性估算](http://physics.stackexchange.com/a/133003)。为什会出现二次函数，因为 $\nabla_w E(W)=\frac{\partial E(w)}{\partial w}$ 。
