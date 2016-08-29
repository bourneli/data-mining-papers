## (2014)Clustering by fast search and find of density peaks.pdf

此论文是2014年发表于science上的一篇基于密度的聚类算法，思路虽然比较简单，但是效果还不错。实现过程中，主要难点是空间检索，但可以基于[kd-tree](http://www.cnblogs.com/eyeszjwang/articles/2429382.html)实现。需要找到一个基于spark实现的kd-tree。

## kd-tree

[这里](http://www.dinkla.net/en/datascience/lbnn.html)有一个基于scala的kd-tree实现，但不是基于spark的，在数据量较大时，可能会有问题。

[这篇文章](http://www.fuqingchuan.com/2014/03/613.html)谈到高纬度空间，kd树效果不一定好，需要使用近似算法。

## Locality-Sensitive Hashing

[这篇文章](http://stackoverflow.com/a/5773066/1114397)介绍了使用LSH(Locality-Sensitive Hashing)来做ANN(Approximate Nearest Neighbor)。LSH就是将相似的对象hash到一起，然后就可以在邻域域得到大致的邻居个数。

[这篇文章](http://blog.csdn.net/icvpr/article/details/12342159)讲得比较清晰，中文阅读效率高。这篇文章没有讲错误评估的推导，但是过程讲的比较清楚，且比较全面。