## (2014) Practical Lessons from Predicting Clicks on Ads at Facebook

在线学习算法BOPR比LR稍微好一点，但是比较复杂，大规模使用性能开销较大，所以没有用。果然大规模后，模型越简单越好。


论文里面提到LR的效果好于GBDT，感觉不太靠谱，可能是在作者的特定场景才这样。LR+GBDT好于GBDT也有点疑惑，在大规模数据场景下LR+GBDT（抽样）的计算明显要小于纯粹的全量GBDT。哪有计算准确率高，还计算性能好这么便宜的事情，感觉全量GBDT效果应该较好。但是这只是猜测，需要在不同数据集合上实验。


论文中还提到了不同学习率的更新策略，这个后面也要仔细研究下。


历史特征的效果强于上下文特征。


训练样本抽样问题

* 均匀采样，10%与100%的效果基本上没有差别
* 负样本采样，不能太少，也不能太多。在2.5%的效果最好。
* 如果父标签重采样，需要校对，参考论文，或者[我的blog](http://bourneli.github.io/machine-learning/prml/2016/12/19/compensating-for-class-priors.html)


虽然本论文主要是GBDT+LR而出名，但是其中介绍了一些实践的细节，是很值得借鉴的。
