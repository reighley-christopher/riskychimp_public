require 'spec_helper'

describe DataColumn do
 # let(:array) { [1, 0, nil] }
  let!(:column) { DataColumn.new([1, 0, nil])}

  describe "sum" do
    it "should return the sum of the non-nil values" do
      column.sum.should == 1
    end
  end

  describe "count" do
    it "should return the number of non-nil values" do
      column.count.should == 2
    end
  end

  describe "mean" do
    it "should return the average of the non-nil values" do
      column.mean.should == 0.5
    end
  end

  describe "median" do
    it "should return the median of the non-nil values" do
      column2 = DataColumn.new([nil, 0.1, 0.2, 0.3, 1000000, 0.0])
      column.median.should == 0.5
      column2.median.should == 0.2
    end
  end

  describe "stdev" do
    it "should return the sample standard deviation of the non-nil values" do
      column.stdev.should be_within(0.01).of(1 / (2 ** 0.5))
    end
  end

  describe "<<" do
    it "should append to the column" do
      column << 2
      column.should == DataColumn.new([1,0,nil,2])
    end
  end

  describe "to_a" do
    it "should return the underlying array" do
      column.to_a.should == [1,0,nil]
    end
  end

  describe "bucketter" do
    it "should return a bucketter that can classify the column entries evenly into categories" do
      col1 = DataColumn.new([nil, 13, 14, 2, 3, 4, 5, 6, nil, 8, 9, 10, nil, 11.5, 12, nil])
      bucketter = col1.bucketter(3)
      bucketter.cutoffs.should == [5.5, 10.75]
      bucketter.bucket(2).should == '(-Infinity, 5.5]'
      bucketter.bucket(5).should == bucketter.bucket(2)
      bucketter.bucket(6).should == '(5.5, 10.75]'
      bucketter.bucket(10).should == bucketter.bucket(6)
      bucketter.bucket(11).should == '(10.75, Infinity)'
      bucketter.bucket(14).should == bucketter.bucket(11)
      bucketter.bucket(nil).should == 'nil'
    end
  end

  describe "#distribution" do
    it "should return a sample distribution function of the data column" do
      col = DataColumn.new([7, 7.2, 7.2, 8, 10, -1, 1.9, 2, 2.1, 3])
      dist = col.sample_distribution
      dist.proportion_under(-1.5).should == 0
      dist.proportion_under(2.05).should == 0.3
      dist.proportion_under(3).should == 0.4
      dist.proportion_under(7.2).should == 0.6
      dist.proportion_under(11).should == 1
    end

    it "should use the order, if given, on the data column values" do
      col = DataColumn.new([:bad, nil, :good, :good, 100])
      order = lambda{ |x,y| [:good, 100, "Hello, World!", nil, :bad].index(x) <=>
          [:good, 100, "Hello, World!", nil, :bad].index(y) }
      dist = col.sample_distribution(order)
      dist.proportion_under(:good).should == 0
      dist.proportion_under(100).should == 0.4
      dist.proportion_under("Hello, World!").should == 0.6
      dist.proportion_under(nil).should == 0.6
    end
  end

  describe "#cast" do
    it "should convert a string to a boolean if I tell it to" do
      col = DataColumn.new(["true", "false", nil])
      col.cast!(:boolean)
      col.to_a.should == [true, false, nil]
    end

    it "should convert a string to a symbol if I tell it to" do
      col = DataColumn.new(["one", "two", "three", nil])
      col.cast!(:categorical)
      col.to_a.should == [:one, :two, :three, nil]
    end

    it "should convert a string to a float if I tell it to" do
      col = DataColumn.new(["0.01", "1", "-0.1", "-2", nil])
      col.cast!(:numeric)
      col.to_a.should == [0.01, 1, -0.1, -2, nil]
    end

    it "should not panic if we call this twice" do
      col = DataColumn.new(["true"])
      col.cast!(:boolean)
      col.cast!(:boolean)
      col.to_a.should == [true]
    end
  end
end