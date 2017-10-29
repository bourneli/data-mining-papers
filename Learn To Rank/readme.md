[机器学习排序之Learning to Rank简单介绍](http://blog.csdn.net/eastmount/article/details/42367515)

主要应用于信息检索，假设查询的文档已被召回，需要对这些召回的文档进行排序。

* 单文档：特征从每个文档单独获取
* 文档对：特征从两个文档获取，模型判断文档1是否应该在文档2前面
* 文档列表：计算个查询函数，然后得到一个文档顺序分布，通过KL度量目标分布与当前分布是否相似判断优劣。

上面这篇博文中说文档列表方法好于前两者。(2010)From RankNet to LambdaRank to LambdaMART An Overview这篇文章介绍的算法是属于文档对。