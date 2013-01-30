#Data for SVM

gen = function(n, m) {
typea_x = rnorm(n, 1, .11)
typea_y = rnorm(n, 2, .12)
typea_label = array(1, n)
x = typea_x
y = typea_y
label = typea_label
typea = data.frame(x, y, label)

typeb_x = rnorm(m, 3, .13)
typeb_y = rnorm(m, 4, .14)
typeb_label = array(-1,m)
x = typeb_x
y = typeb_y
label = typeb_label
typeb = data.frame(x, y, label)

rbind(typea, typeb)
}

write.csv(gen(20,20), '~/code/riskybiz/R/training_coords.csv')
write.csv(gen(100,100), '~/code/riskybiz/R/testing_coords.csv')