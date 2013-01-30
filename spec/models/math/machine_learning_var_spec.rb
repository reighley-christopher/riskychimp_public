require 'spec_helper'

describe "machine_learning_var.rb" do
  let(:good_transaction) { FactoryGirl.create(:good_transaction) }

  describe "explanatory_variable svm" do

    before :all do
      @user = FactoryGirl.create(:user)
      load('./lib/other/static_sample.rb') #TODO: should not need to create all these transactions
      Transaction.update_all(:client_id => @user.id)
    end

    after :all do
      Transaction.delete_all
      @user.delete
    end

    it "should return a boolean" do
      sample = PromissoryObject.new(TrainingSample, ["./lib/data/training_data_0.csv"])

      var = ExplanatoryVariable.lookup(:svm)
      var.evaluate(good_transaction, :sample => sample).should satisfy do |bool|
        bool == true || bool == false
      end
    end

    it "should flag about 50% of the transactions as 'fraudy'" do
      var = ExplanatoryVariable.lookup(:svm)
      trans = Transaction.scoped
      sample = PromissoryObject.new(TrainingSample, ['./lib/data/training_data_0.csv'])
      tested_fraud_rate = (trans.map{ |tr|
        var.evaluate(tr, sample: sample) ? 1.0 : 0.0
      }.sum / trans.count)
      tested_fraud_rate.should be_within(0.1).of(0.50)
    end
  end

  describe "explanatory_variable id3" do
    before :all do
      load('./lib/other/static_sample.rb') #TODO: should not need to create all these transactions
      @sample = TrainingSample.new('lib/data/training_data_0.csv')
    end

    after :all do
      Transaction.delete_all
    end

    it "should return a boolean" do
      var = ExplanatoryVariable.lookup(:id3)
      var.evaluate(good_transaction, sample: @sample).should satisfy { |bool| bool == true || bool == false }
    end

    it "should flag about 50% of the transactions as 'fraudy'" do
      var = ExplanatoryVariable.lookup(:id3)
      tested_fraud_rate = (Transaction.all.map{ |tr| var.evaluate(tr, sample: @sample) ? 1.0 : 0.0}.sum / Transaction.count)
      tested_fraud_rate.should be_within(0.1).of(0.50)
    end
  end

  describe "explanatory_variable reliability_score" do
    it "should compute a number between 0 and 100" do
      var = ExplanatoryVariable.lookup(:reliability_score)
      var.evaluate(good_transaction).should <= 100
      var.evaluate(good_transaction).should >= 0
    end
  end
end
