require 'spec_helper'

describe "misc_var.rb" do

  let(:good_transaction) { FactoryGirl.create(:good_transaction,
                                               amount: 50.00,
                                               transaction_datetime: DateTime.parse("2011-12-06 00:14:39 +00:00"),
                                               other_data: { account_zip: "94022 " }) }
  let(:almost_good_transaction) { FactoryGirl.create(:good_transaction,
                                               amount: 50.00,
                                               transaction_datetime: nil,
                                               other_data: { account_zip: nil }) }

  describe "explanatory_variable local_time" do
    it "should return the local time (in hours since midnight) of the transaction" do
      var = ExplanatoryVariable.lookup(:local_time)
      var.evaluate(good_transaction).should be_within(0.02).of(16.25)
    end
  end

  describe "explanatory_variable amount" do
    it "should return the amount field" do
      var = ExplanatoryVariable.lookup(:amount)
      var.evaluate(good_transaction).should == 50.00
    end
  end

  describe "explanatory_variable nonnull_count" do
    it "should return the number of non-null fields" do
      var = ExplanatoryVariable.lookup(:nonnull_count)
      good_count = var.evaluate(good_transaction)
      almost_count =  var.evaluate(almost_good_transaction)
      super_bad_count = var.evaluate(Transaction.new)
      super_bad_count.should >= 0
      almost_count.should >= super_bad_count
      (good_count - almost_count).should == 2
    end
  end

  describe "explanatory_variable null_count" do
    it "should return the number of named fields with nulls" do
      var = ExplanatoryVariable.lookup(:null_count)
      good_count = var.evaluate(good_transaction)
      almost_count =  var.evaluate(almost_good_transaction)
      super_bad_count = var.evaluate(Transaction.new)
      good_count.should >= 0
      (almost_count - good_count).should == 2
      super_bad_count.should >= almost_count
    end
  end

  describe "explanatory_variable nonnull_hash" do
    it "should return a hashed alphabetical list of the nonnull/nonnil attributes" do
      var = ExplanatoryVariable.lookup(:nonnull_hash)
      var.evaluate(Transaction.create()).should == Digest::SHA1.hexdigest("")
      var.evaluate(Transaction.create(email: nil, other_data: nil)).should == Digest::SHA1.hexdigest("")
      var.evaluate(Transaction.create(email: "john@google.com",
                                      other_data: { account_zip: 94022, account_city: nil })).should ==
          Digest::SHA1.hexdigest("account_zipemail")
    end
  end
end