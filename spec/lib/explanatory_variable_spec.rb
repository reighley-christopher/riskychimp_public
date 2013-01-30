require 'spec_helper'

describe ExplanatoryVariable do
  before :all do
    @test_file = <<-DSL_EXAMPLE
      explanatory_variable :test_variable do
        type :boolean
        input Object
        description "this is a test variable that returns true for any input"
        calculate do |trans|
          next true
          false
        end
      end

      explanatory_variable :test_variable2 do
        type :numeric
        input Object
        description "this is a test variable that accepts any input and calls its :number method"
        calculate do |trans|
          2 * trans.number
        end
      end

      explanatory_variable :test_variable3 do
        type :numeric
        input Object
        asset :m do
          20
        end
        description "this returns 25 every time, 20 is a precomputed constant, addition of 5 is computed for each transaction"
        calculate do |trans|
          m + 5
        end
      end

      explanatory_variable :test_variable4 do
        type :numeric
        input Object
        dependencies :test_variable3, :test_variable2
        description "this is a test variable that computes the natural logarithm of a different test variable"
        calculate do |trans|
          Math.log(test_variable3 + test_variable2)
        end
      end

      explanatory_variable :test_variable5 do
        type :numeric
        input Object
        dependencies :test_variable6
        description "this is a test variable that looks up another variable that looks up this one"
        calculate do |trans|
          test_variable6
        end
      end

      explanatory_variable :test_variable_half_past_5 do
        type :numeric
        input Object
        dependencies :test_variable_half_past_5
        description "this is a test variable that looks up itself"
        calculate do |trans|
          test_variable_half_past_5
        end
      end

      explanatory_variable :test_variable6 do
        type :numeric
        input Object
        dependencies :test_variable5, :test_variable6
        description "this is a test variable that looks up another variable that looks up this one"
        calculate do |trans|
          test_variable5 + test_variable6
        end
      end

      explanatory_variable :x do
        type :numeric
        input Object
        description "this is an explanatory variable which is intended to correspond to the x column in the test_training_data sample"
        calculate do |trans|
          trans.number
        end
      end

      explanatory_variable :test_variable7 do
        type :numeric
        input Object
        description "this variable uses a training sample, which hopefully it has inherited"
        dependencies :x
        calculate do |trans|
          x - sample.mean(:x)
        end
      end

      explanatory_variable :test_variable8 do
        type :numeric
        input Object
        description "this variable has a training sample, and visibility to its statistics"
        dependencies :test_variable7
        calculate do |trans|
          test_variable7 / sample.stdev(:x)
        end
      end

      explanatory_variable :test_variable9 do
        type :numeric
        input Object
        description "this variable has a different training sample"
        dependencies :test_variable7
        calculate do |trans|
          test_variable7 / sample.stdev(:x)
        end
      end

      explanatory_variable :test_variable10 do
        type :numeric
        input Object
        description "this variable calls one of its dependencies twice in the calculate block"
        dependencies :test_variable2
        calculate do |trans|
          test_variable2 / test_variable2
        end
      end

      explanatory_variable :exploding_variable do
        type :boolean
        input Object
        description "this variable raises an error in calculate"
        calculate do |trans|
          raise "I 'SPLODE!!!'"
        end
      end

      explanatory_variable :test_variable11 do
        type :numeric
        input Object
        description "this has its own sample it expects test_variable8 to be using"
        dependencies :test_variable8
        calculate do |trans|
          test_variable8
        end
      end

      explanatory_variable :var_with_sample_but_no_dependency do
        type :numeric
        input Object
        description "this has its own sample but no dependencies"
        calculate do |trans|
          50 - sample.mean(:x)
        end
      end

    DSL_EXAMPLE
    eval(@test_file, binding)
  end

  let :test_object do
    obj = Object.new
    obj.define_singleton_method(:number) { 10 }
    obj
  end

  it "should be able to see the test_variable" do
    ExplanatoryVariable.catalog.should_not be_empty
  end

  it "should have the information we gave it" do
    var = ExplanatoryVariable.lookup(:test_variable)
    var.name.should == :test_variable
    var.type.should == :boolean
    var.input.should == Object
    var.description.should == "this is a test variable that returns true for any input"

  end

  it "should call the evaluation procedure and return the correct value" do
    var = ExplanatoryVariable.lookup(:test_variable)
    var.evaluate(test_object).should == true
  end

  it "should overwrite a variable of the same name" do
    size = ExplanatoryVariable.catalog.size
    eval(@test_file, binding)
    ExplanatoryVariable.catalog.size.should == size
  end

  it "should have access to the contents of its parameter" do
    var = ExplanatoryVariable.lookup(:test_variable2)
    var.evaluate(test_object).should == 20
  end

  it "should set the asset variable equal to the result of the passed block" do
    var = ExplanatoryVariable.lookup(:test_variable3)
    var.evaluate(test_object).should == 25
  end

  it "should be able to build one explanatory variable from another" do
    old_var = ExplanatoryVariable.lookup(:test_variable3)
    old_val = old_var.evaluate(test_object)
    another_old_var = ExplanatoryVariable.lookup(:test_variable2)
    another_old_val = another_old_var.evaluate(test_object)
    new_var = ExplanatoryVariable.lookup(:test_variable4)
    new_var.evaluate(test_object).should be_within(0.01).of(Math.log(old_val + another_old_val))
  end

  it "should raise an error if somebody accidentally self references (it should not enter an infinite loop)" do
    var = ExplanatoryVariable.lookup(:test_variable5)
    var2 = ExplanatoryVariable.lookup(:test_variable_half_past_5)
    expect {
      var.evaluate(test_object)
    }.to raise_error SelfReferenceError
    expect {
      var2.evaluate(test_object)
    }.to raise_error SelfReferenceError
  end

  it "should raise an error if sample statistics are referenced in the calculate block but sample has not been defined" do
    var = ExplanatoryVariable.lookup(:test_variable7)
    expect {
      var.evaluate(test_object)
    }.to raise_error NoSampleError
  end

  it "should be able to pass sample training data to its dependencies" do
    sample = TrainingSample.new('spec/lib/test_training_data.csv')
    var = ExplanatoryVariable.lookup(:test_variable8)
    testval = var.evaluate(test_object, sample: sample)
    testval.should be_within(0.01).of((10 - 0.5) / 0.5)
  end

  it "should be able to use different training sets for different explanatory variables" do
    sample8 = TrainingSample.new('spec/lib/test_training_data.csv')
    sample9 = TrainingSample.new('spec/lib/test_training_data2.csv')
    var = ExplanatoryVariable.lookup(:test_variable8)
    another_var = ExplanatoryVariable.lookup(:test_variable9)

    var.evaluate(test_object, sample: sample8).should be_within(0.01).of((10 - 0.5) / 0.5)
    another_var.evaluate(test_object, sample: sample9).should be_within(0.01).of((10 - 100.5) / (2 ** -0.5))
  end

  it "should make sure that an isolated variable doesn't accidentally pick up a sample from a prior" do
    sample = TrainingSample.new('spec/lib/test_training_data.csv')
    var1 = ExplanatoryVariable.lookup(:test_variable8)
    var1.evaluate(test_object, sample: sample).should > 0

    var2 = ExplanatoryVariable.lookup(:test_variable7)
    expect {
      var2.evaluate(test_object)
    }.to raise_error NoSampleError
  end

  it "should not throw a NoSampleError if a sample is passed to evaluate" do
    var2 = ExplanatoryVariable.lookup(:test_variable7)
    sample = TrainingSample.new("spec/lib/test_training_data.csv")
    var2.evaluate(test_object, sample: sample).should == 9.5
  end

  #samples are now passed explicitly
  #it "should temporarily, but not permanently, overwrite a sample with one which is passed to evaluate" do
  #  var = ExplanatoryVariable.lookup(:var_with_sample_but_no_dependency)
  #  sample = TrainingSample.new("spec/lib/test_training_data2.csv")
  #  var.evaluate(test_object).should == 49.5
  #  var.evaluate(test_object, sample: sample).should == -50.5
  #  var.evaluate(test_object).should == 49.5
  #end


# samples are now passed explicitly
#  it "should give priority to the outermost sample" do
#    var1 = ExplanatoryVariable.lookup(:test_variable11)
#    var2 = ExplanatoryVariable.lookup(:test_variable8)
#    var1.evaluate(test_object).should_not == var2.evaluate(test_object)
#  end

  it "should be able to call evaluate on a hash (instead of on a Transaction)" do
    var = ExplanatoryVariable.lookup(:test_variable4)
    hash = { test_variable2: 1, test_variable3: 2 }
    var.evaluate(nil, precomputed_values: hash).should be_within(0.01).of Math.log(3)
  end

  it "should be able to use a mix of precomputed and live data" do
    var = ExplanatoryVariable.lookup(:test_variable4)
    hash = { test_variable3: 2 }
    var.evaluate(test_object, precomputed_values: hash).should be_within(0.01).of Math.log(22)
  end

  it "should be able to handle the trivial case in which precomputed values are only one layer deep" do
    var = ExplanatoryVariable.lookup(:test_variable4)
    hash = { test_variable4: 5 }
    var.evaluate(nil, precomputed_values: hash).should == 5
  end

  it "should be able to reference the same dependency more than once in the calculate block" do
    var = ExplanatoryVariable.lookup(:test_variable10)
    var.evaluate(test_object).should == 1
  end

  it "should evaluate to nil if something went horribly wrong in calculate" do
    var = ExplanatoryVariable.lookup(:exploding_variable)
    var.evaluate(test_object).should be_nil
    var.last_error.message.should == "I 'SPLODE!!!'"
  end

  it "should use values from the context, if available, instead of values from its assets" do
    var = ExplanatoryVariable.lookup(:test_variable3)
    ctx = { m: 30 }
    var.evaluate(test_object, context: ctx).should == 35
    var.evaluate(test_object).should == 25
  end
end