ol <- read.csv("d:\\dnf_role_ol_sample.csv")
head(ol)

require(ggplot2)

qplot(x = online_time,data = ol)
summary(ol)
sum(ol$online_time == 0)


quantile(ol$online_time,seq(0,1,0.05))
