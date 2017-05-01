
[Macheine Learning for Trading 课程地址](https://classroom.udacity.com/courses/ud501)

这门课程主要介绍机器学习在股票交易中的应用，是佐治亚立功大学教授Tucker Balch开设的，他好像还参与创建了一个对冲基金公司，利用这门课程里的技术，进行基金运作。


本课程分为三个部分，前两个部分主要是介绍数据清理和领域知识，我直接跳过了，直接看第三部分。

## Section 3.1  How Machine Learning is used at a hedge fund
第三部分，开始介绍什么是回归学习和一些常用模型。有一个demo令人映像深刻，使用KNN算法帮助机器人躲避障碍。其实本质上是一个二元分类问题，判断当前图片是否是障碍，如果不是就直接走，否则就换个方向。demo视频中的效果还不错。股票价格预测中，使用时间窗口切分训练和预测，与付费预测很类似。

## Section 3.2 Regression

加农炮问题，使用参数方法（线性回归）求解，因为此问题可以用明确的数学方程来求解，所以可以通过数据学习参数。此问题是biased,因为我们会猜测这个方程的形式，二次，三角，指数等。

蜜蜂问题，由于问题无法用明确的数学公式求解，使用非参数（kNN）方法更为合适。无偏估计，因为使用均值。

## Section 3.3 Assessing a learning algorithm
