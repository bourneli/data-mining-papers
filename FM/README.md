## (2010)Factorization Machines

一种分类器，可以处理非常稀疏的超大矩阵，而SVM不行。与核函数为多项式的SVM的工作原理类似。本质上是考虑了多个变量之间的交互。

相关参考

* [美团FFM](http://tech.meituan.com/deep-understanding-of-ffm-principles-and-practices.html)
* [新浪FM/FFM](http://www.52caml.com/head_first_ml/ml-chapter9-factorization-family/#)



https://github.com/Intel-bigdata/FM-Spark

http://tech.meituan.com/deep-understanding-of-ffm-principles-and-practices.html


http://blog.csdn.net/itplus/article/details/40534885

https://getstream.io/blog/factorization-machines-recommendation-systems/

http://baogege.info/2014/10/19/matrix-factorization-in-recommender-systems/

线性回归算法
http://blog.kamidox.com/gradient-descent.html


如果作为分类器，需要使用Logit Loss函数作为损失函数，定义如下

$$
  L(\theta) = \ln{(1+e^{-yf(x,\theta)})}, y \in \{-1,1\},f(x,\theta)可以使线性回归，也可以是FM
$$

对Logit Loss求导

$$
  \frac{\partial L}{\partial \theta_i} = \frac{-ye^{-yf(x,\theta)}}{1+e^{-yf(x,\theta)}} \frac{\partial f(x,\theta)}{\partial \theta_i} = \frac{-y}{1+e^{yf(x,\theta)}}    \frac{\partial f(x,\theta)}{\partial \theta_i} = -y(1-\frac{1}{1+e^{-yf(x,\theta)}})\frac{\partial f(x,\theta)}{\partial \theta_i}

$$

了解fm
还要找fm 二元分类实现



km上有一篇文章，[SNG使用FM做的推荐](http://km.oa.com/group/22605/articles/show/292186?kmref=search&from_page=1&no=5),基于github上的一个[spark-libFM](https://github.com/zhengruifeng/spark-libFM/blob/master/src/main/scala/org/apache/spark/mllib/regression/FactorizationMachine.scala)开源实现修改的，使用了logit loss和cross entropy两个函数，线上效果后者较好，后面可以尝试。

[spark-libFM](https://github.com/zhengruifeng/spark-libFM/blob/master/src/main/scala/org/apache/spark/mllib/regression/FactorizationMachine.scala)直接使用的spark mllib优化器，我只需要实现梯度就可以了，太棒了！可以获取中间输出结果，得到是否收敛。已经实现了二元梯度，看看梯度的实现。
