require 'spec_helper'

describe FraudModel do
  let(:user) { FactoryGirl.create(:merchant) }

  let!(:good_transaction) { FactoryGirl.create(:good_transaction, user: user, amount: 50) }
  let!(:bad_transaction) { FactoryGirl.create(:bad_transaction, user: user, amount: 200) }
  let!(:extreme_transaction) { FactoryGirl.create(:bad_transaction, user: user, amount: 1000000) }
  let!(:tiny_transaction) { FactoryGirl.create(:good_transaction, user: user, amount: 5) }

  let(:model) { user.fraud_model }

  describe "#reliability_score" do
    it "should return a number between 0 and 100" do
      score = model.reliability_score(good_transaction)
      score.should be >= 0
      score.should be <= 100
    end

    it "should give a higher score to a bad transaction than a good transaction" do
      model.reliability_score(bad_transaction).should > model.reliability_score(good_transaction)
      #TODO: rename; it's a fraud score, not a reliability score
    end
  end

  describe "#explain_factor" do
    it "should return a string describing how much this factor affected the score" do
      explanation = model.explain_factor(model.reliability_score(good_transaction), :amount)
      explanation.should match /The amount factor accounted for [0-9]*% of the score\./
      explanation.should match /This transaction's amount was worse than [0-9]*% of transactions in the sample\./
      explanation.should match /the amount of the transaction/
      explanation.should include "50"
    end
  end

  describe "#explain" do
    it "should return a string " do
      explanation = model.explain(model.reliability_score(good_transaction))
      explanation.should be_kind_of(String)
      explanation.should be_present
    end

    it "should not raise an error for an extreme transaction" do
      expect {
        score = model.reliability_score(extreme_transaction)
        explanation = model.explain(score)
      }.not_to raise_error
    end

    it "should not raise an error for a perfect transaction" do
      expect {
        score = model.reliability_score(tiny_transaction)
        explanation = model.explain(score)
      }.not_to raise_error
    end
  end

  describe "#factor_details" do
    let(:proportion_value) { 0.1 }
    let(:quantile_value) { 0.2 }
    let(:value) { 0.3 }
    let(:factor) { :amount }

    before do
      @score = mock
      @score.stub(:proportion_of_score).and_return(factor => proportion_value)
      @score.stub(:quantile_of_feature).and_return(factor => quantile_value)
      @score.stub(:value_of_feature).and_return(factor => value)
    end

    it "should return details of each factor" do
      description = ExplanatoryVariable.lookup(factor).description.titleize
      model.factor_details(@score, factor).should ==
        {:value => value, :proportion => (proportion_value*100).floor,
         :quantile => (quantile_value*100).floor, :description => description }
    end
  end

  describe "#extracted_factors" do
    before do
      @score = double("Score")
    end

    it "shouldn't return unaffected factors and should order by the importance of factors" do
      @score.stub(:proportion_of_score).and_return({:factor1 => 1, :factor2 => 2, :factor3 => 0})
      model.extracted_factors(@score).should == [:factor2, :factor1]
    end

    it "should return top 5 factors" do
      @score.stub(:proportion_of_score).and_return({:factor1 => 10, :factor2 => 9, :factor3 => 8,
                                                    :factor4 => 7, :factor5 => 6, :factor6 => 5})
      model.extracted_factors(@score).should == [:factor1, :factor2, :factor3, :factor4, :factor5]
    end
  end

  describe "initialize" do
    it "should create a sane model if class is a just a string" do
      merchant = FactoryGirl.create(:merchant)
      f = FraudModel.new(merchant_id: merchant.id, class: "Scorer::OutlierOrder" )
    end

    it "should create a sane model if terms is just a string" do
      merchant = FactoryGirl.create(:merchant)
      f = FraudModel.new(merchant_id: merchant.id, model_params_string: Scorer::OutlierOrder.default_model_params.to_json )
    end

    it "should raise an error if unknown arguments are given" do
      merchant = FactoryGirl.create(:merchant)
      expect {
        f = FraudModel.new(merchant_id: merchant.id, crazy_key: 15 )
      }.to raise_error
    end
  end
end
