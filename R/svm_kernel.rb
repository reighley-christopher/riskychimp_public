require 'csv'
require 'svm'

training = CSV.read('./R/training_coords_kernel.csv')
training_data = training.map { |tr| [tr[1].to_f, tr[2].to_f] }.slice(1, 41)
training_labels = training.map { |tr| tr[3].to_f }.slice(1,41)

prob = Problem.new(training_labels,training_data)
param = Parameter.new(:kernel_type => RBF, :C => 10)
m = Model.new(prob,param)

testing = CSV.read('./R/testing_coords_kernel.csv')
testing_data = testing.map { |tr| [tr[1].to_f, tr[2].to_f] }.slice(1, 1000)
testing_labels = testing.map { |tr| tr[3].to_f }.slice(1,1000)
tested_labels = testing_data.map { |coord| m.predict(coord) }

p "These one's aren't equal: "
p (0..200).select {|i| testing_labels[i] != tested_labels[i]}

m.save("./R/model_kernel.svm")