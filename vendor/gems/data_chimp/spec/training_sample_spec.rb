require 'spec_helper'

describe "TrainingSample" do
  before :all do
    explanatory_variable(:x) { type :numeric }
    explanatory_variable(:y) { type :numeric }
  end
  let(:training_sample) { TrainingSample.new("./spec/lib/test_training_data.csv") }

  describe "initialize" do
    let(:other_sample) { TrainingSample.new([trans], [:amount, :email_match]) }
    let(:trans) { FactoryGirl.create(:good_transaction, amount: 100) }

    it "should initialize a sample from either 1) a csv file, or 2) an array of transactions and an array of EV's" do
      other_sample.size.should == 1
      other_sample.mean(:amount).should == 100
    end

    #TODO: decide what to do about the difference between a sample initialized from a csv vs. a list of transactions
    #TODO:   (for example, a value being stored as "true" vs. :true)
  end

  describe "#size" do
    it "should return the size of the sample" do
      training_sample.size.should == 3
    end
  end

  describe "#mean" do
    it "should compute the sample mean of its numeric columns" do
      training_sample.mean(:x).should == 0.5
      training_sample.mean(:y).should == 0.5
    end
  end

  describe "#stdev" do
    it "should compute the sample standard deviation" do
      training_sample.stdev(:x).should be_within(0.01).of(0.5)
      training_sample.stdev(:y).should be_within(0.01).of(0.5)
    end
  end

  describe "#bucketter" do
    it "should produce a bucketter for the column of this name" do
      training_sample.bucketter(:x, 3).cutoffs.should == [0.25, 0.75]
    end
  end

  describe "#[]" do
    it "should lookup columns by name" do
      training_sample[:x].should == [1.0, 0.0, 0.5]
      training_sample[:category].should == ["true", "false", "true"]
    end
  end

  describe "#hashify" do
    it "should create a hash with column names from an array" do
      training_sample.hashify(["true", 0, 1]).should == { category: "true", x: 0, y: 1 }
    end
  end

  describe "#find_row" do
    it "should lookup a row by index" do
      training_sample.find_row(0).should == ["true", 1.0, 0.0]
      training_sample.find_row(1).should == ["false", 0.0, 1.0]
      training_sample.find_row(2).should == ["true", 0.5, 0.5]
    end
  end

  describe "#sample_distribution" do
    it "should produce an estimated cumulative distribution function" do
      dist = training_sample.sample_distribution(:x)
      dist.proportion_under(0.75).should > 0.66
      dist.proportion_under(1).should <= 1
      dist.proportion_under(0).should >= 0
      dist.proportion_under(0.5).should >= 0.33
    end
  end

  describe "#write_to_csv" do
    before :all do
      if File.exists?('./spec/lib/training_sample_write.rb')
        raise "this test expected that the file /spec/lib/training_sample_write.csv did not exist, " +
                  "but it did and I panicked"
      end
    end

    after :all do
      File.delete('./spec/lib/training_sample_write.rb')
    end

    it "should write the sample to a csv file" do
      training_sample.write_to_csv('./spec/lib/training_sample_write.rb')
      duplicate_sample = TrainingSample.new('./spec/lib/training_sample_write.rb')
      duplicate_sample.size.should == training_sample.size
      duplicate_sample.col_names.should == training_sample.col_names
      duplicate_sample[:y].should == training_sample[:y]
    end
  end
end