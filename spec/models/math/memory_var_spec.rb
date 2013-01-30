require 'spec_helper'

describe "memory_var.rb" do
  let(:strange_client) {FactoryGirl.create(:user)}
  let(:good_client) {FactoryGirl.create(:user)}

  let(:other_strange_transaction) { FactoryGirl.create(:good_transaction,
                                                  purchaser_id: "happy",
                                                  user: strange_client,
                                                  ip: "8.8.8.7",
                                                  other_data: { cc_digest: "2346" },
                                                  device_id: "1111111111111111111111111111111111111112",
                                                  transaction_datetime: DateTime.parse("1998-12-31 23:58:22 -08:00").utc
  )}

  let(:strange_transaction) { FactoryGirl.create(:good_transaction,
                                                  purchaser_id: "somebodyelse",
                                                  user: strange_client,
                                                  ip: "8.8.8.7",
                                                  other_data: { cc_digest: "2346" },
                                                  device_id: "1111111111111111111111111111111111111112",
                                                  transaction_datetime: DateTime.parse("1999-12-31 23:58:22 -08:00").utc
  )}

  let(:almost_good_transaction) { FactoryGirl.create(:good_transaction,
                                                      purchaser_id: "happy",
                                                      user: good_client,
                                                      ip: "8.8.8.8",
                                                      other_data: { cc_digest: "1234" },
                                                      device_id: "1111111111111111111111111111111111111111",
                                                      transaction_datetime: DateTime.parse("2011-12-03 17:20:39 -08:00").utc
  )}

  let(:good_transaction) { FactoryGirl.create(:good_transaction,
                                               purchaser_id: "happy",
                                               user: good_client,
                                               ip: "8.8.8.8",
                                               other_data: { cc_digest: "1234" },
                                               device_id: "1111111111111111111111111111111111111111",
                                               transaction_datetime: DateTime.parse("2011-12-05 16:14:39 -08:00").utc
  )}

  let(:bad_transaction)  { FactoryGirl.create(:good_transaction,
                                               purchaser_id: "happy",
                                               user: good_client,
                                               ip: "8.8.8.8",
                                               other_data: { cc_digest: "2345" },
                                               device_id: "1111111111111111111111111111111111111111",
                                               transaction_datetime: DateTime.parse("2011-12-05 17:10:22 -08:00").utc
  )}

  before :each do
    strange_client.reload
    good_client.reload
    other_strange_transaction.reload
    strange_transaction.reload
    almost_good_transaction.reload
    good_transaction.reload
    bad_transaction.reload
  end

  describe "explanatory_variable cards_by_ip" do
    it "should return the number of distinct credit cards used from this transaction's ip " +
           "(only counting transactions at or before transaction_datetime)" do
      var = ExplanatoryVariable.lookup(:cards_by_ip)
      var.evaluate(good_transaction).should == 1
      var.evaluate(bad_transaction).should == 2
    end
  end

  describe "explanatory_variable cards_by_print" do
    it "should return the number of distinct credit cards used from a browser with this transaction's fingerprint " +
           "(only counting transactions at or before transaction_datetime)" do
      var = ExplanatoryVariable.lookup(:cards_by_print)
      var.evaluate(good_transaction).should == 1
      var.evaluate(bad_transaction).should == 2
    end
  end

  describe "explanatory_variable frequency_of_ip" do
    it "should return the number of transactions from this ip " +
           "(only counting transactions at or before transaction_datetime)" do
      var = ExplanatoryVariable.lookup(:frequency_of_ip)
      var.evaluate(good_transaction).should == 2
      var.evaluate(bad_transaction).should == 3
    end
  end

  describe "explanatory_variable frequency_of_print" do
    it "should return the number transactions from browser with this transaction's fingerprint " +
           "(only counting transactions at or before transaction_datetime)" do
      var = ExplanatoryVariable.lookup(:frequency_of_print)
      var.evaluate(almost_good_transaction).should == 1
      var.evaluate(good_transaction).should == 2
      var.evaluate(bad_transaction).should == 3
    end
  end

  describe "explanatory_variable customer_loyalty" do
    it "should return the number of transactions by this transaction's purchaser id " +
           "(only counting transactions at or before transaction_datetime)" do
      var = ExplanatoryVariable.lookup(:customer_loyalty)
      var.evaluate(good_transaction).should == 2
      var.evaluate(bad_transaction).should == 3
    end
  end

  describe "explanatory_variable frequency_of_ip_today" do
    it "should return the number of transactions from this ip today" do
      var = ExplanatoryVariable.lookup(:frequency_of_ip_today)
      var.evaluate(almost_good_transaction).should == 1
      var.evaluate(good_transaction).should == 1
      var.evaluate(bad_transaction).should == 2
    end
  end

  describe "explanatory_variable frequency_of_print_today" do
    it "should return the number of transactions from browser with this transaction's fingerprint today" do
      var = ExplanatoryVariable.lookup(:frequency_of_print_today)
      var.evaluate(almost_good_transaction).should == 1
      var.evaluate(good_transaction).should == 1
      var.evaluate(bad_transaction).should == 2
    end
  end
end
