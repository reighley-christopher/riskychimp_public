require 'spec_helper'

describe "location_var.rb" do
  let(:good_transaction) { FactoryGirl.create(:good_transaction,
                                               ip: "8.8.8.8",
                                               shipping_city: "Mountain View",
                                               shipping_state: "CA",
                                               shipping_zip: "94043",
                                               shipping_country: "US",
                                               other_data:    { account_address: "NULL ",
                                                                account_city: "Los Altos ",
                                                                account_zip: "94022 ",
                                                                account_country: "us ",
                                                                account_city: "Los Altos "})
  }

  describe "explanatory_variable addr_la" do
    it "should return the distance between location address and account address" do
      var = ExplanatoryVariable.lookup(:addr_la)
      var.evaluate(good_transaction).should be_within(5).of(5)
    end
  end

  describe "explanatory_variable addr_li" do
    it "should return the distance between location address and IP address" do
      var = ExplanatoryVariable.lookup(:addr_li)
      var.evaluate(good_transaction).should be_within(5).of(0)
    end
  end

  describe "explanatory_variable addr_ia" do
    it "should return the distance between IP address and account address" do
      var = ExplanatoryVariable.lookup(:addr_ia)
      var.evaluate(good_transaction).should be_within(5).of(5)
    end
  end
end