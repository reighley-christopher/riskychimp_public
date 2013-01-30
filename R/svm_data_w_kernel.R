#Data for SVM

circle_gen = function(n, m) {
typea_x = rnorm(n, 0, .11)
typea_y = rnorm(n, 0, .12)
typea_label = array(1, n)
x = typea_x
y = typea_y
label = typea_label
typea = data.frame(x, y, label)

typeb_x_noise = rnorm(m, 0, .13)
typeb_y_noise = rnorm(m, 0, .14)
typeb_angle = runif(m, 0, 2*pi)
typeb_label = array(-1,m)
x = cos(typeb_angle) + typeb_x_noise
y = sin(typeb_angle) + typeb_y_noise
label = typeb_label
typeb = data.frame(x, y, label)

rbind(typea, typeb)
}

write.csv(circle_gen(20,20), '~/code/riskybiz/R/training_coords_kernel.csv')
write.csv(circle_gen(100,100), '~/code/riskybiz/R/testing_coords_kernel.csv')