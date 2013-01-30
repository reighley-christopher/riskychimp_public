require 'spec_helper'

describe Classifier do
  before :all do
    explanatory_variable :x do
      type :numeric
      calculate
    end

    explanatory_variable :y do
      type :numeric
      calculate
    end
  end

  describe Classifier::SVMachine do
    describe "#initialize" do
      it "should throw a named exception when given an invalid file name" do
        expect {
          Classifier::SVMachine.new(TrainingSample.new("nonexistant.file"), [:x, :y])
        }.to raise_error IOError
      end
    end

    describe "#predict" do
      let(:model) { Classifier::SVMachine.new(TrainingSample.new("./spec/lib/test_training_data.csv"), [:x, :y]) }
      it "correctly classify a vector" do
        model.predict([1,0]).should == true
        model.predict([0,1]).should == false
      end
    end
  end

  describe Classifier::DecisionTreeID3 do
    describe "#initialize" do
      it "should throw a named exception when given an invalid file name" do
        expect {
          Classifier::DecisionTreeID3.new(TrainingSample.new("nonexistant.file"), [:x, :y])
        }.to raise_error IOError
      end
    end

    describe "#predict" do
      let(:model) { Classifier::DecisionTreeID3.new(TrainingSample.new("./spec/lib/test_training_data.csv"), [:x, :y]) }
      it "correctly classify a vector" do
        model.predict([1,0]).should == true
        model.predict([0,1]).should == false
      end
    end
  end

  describe Classifier::SASDecisionTree do
    let(:model) { Classifier::SASDecisionTree.new("./spec/lib/sas_decision_tree_test_model.sas") }

    describe "#predict" do
      it "correctly classify a vector" do
        model.predict([1,1]).should == true
        model.predict([0,0]).should == true
        model.predict([1,0]).should == true
        model.predict([0,1]).should == false
      end
    end
  end
end