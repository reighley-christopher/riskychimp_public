require('csv')
require('svm')

module SVM
  # This module is to prevent Model (which is in svm without a namespace) from
  # shadowing the Model which is under Classifier
  def self.model
    Model
  end
end

module Classifier
  class SVMachine
    def initialize(sample, column_names)
      training_categories = sample[:category].map { |val| val == "true" ? 1.0 : -1.0 }

      evs = {}
      column_names.each { |sym| evs[sym] = ExplanatoryVariable.lookup(sym) }

      training_data = (0...sample.size).map do |val|
        column_names.map do |var|
          if evs[var].nil?
            sample.hashify(sample.find_row(val))[var] #TODO refactor
          else
            evs[var].evaluate(nil, precomputed_values: sample.hashify(sample.find_row(val)), sample: sample)
          end
        end
      end

      prob = Problem.new(training_categories, training_data)
      param = Parameter.new(:kernel_type => LINEAR, :C => 100)
      @m = SVM::model.new(prob,param)
    end

    def predict(vector)
      @m.predict(vector) > 0
    end
  end

  class Ai4r::Classifiers::EvaluationNode
    def rule_not_found
      "no rule found"
    end
  end

  class DecisionTreeID3
    def initialize(sample, column_names)
      category = sample[:category]
      evs = {}
      column_names.each { |sym| evs[sym] = ExplanatoryVariable.lookup(sym) }

      training_data = (0...sample.size).map do |val|
        column_names.map do |var|
          if evs[var].nil?
            sample.hashify(sample.find_row(val))[var] #TODO refactor
          else
            evs[var].evaluate(nil, precomputed_values: sample.hashify(sample.find_row(val)), sample: sample)
          end
        end << category[val]
      end

      dataset = Ai4r::Data::DataSet.new( data_items: training_data, data_labels: column_names << :category)
      @m = Ai4r::Classifiers::ID3.new.build(dataset)
    end

    def predict(vector)
      @m.eval(vector) == "true"
    end
  end

  class SASDecisionTree
    def initialize(filename) #TODO: use the filename
    end

    def node(x,y)
      if !x.blank? && 1.02614315873885 <=x
        return 3
      end
      if !x.blank? && x < 0.49264908877269
        if !y.blank? && 0.500322369158 <= y
          return 7
        else
          return 6
        end
      else
        return 5
      end
    end

    def predict(vector)
      x = vector[0]
      y = vector[1]

      if [3,6,5].include? node(x,y)
        return true
      elsif [7].include? node(x,y)
        return false
      else
        return nil
      end
    end
  end
end