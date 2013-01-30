require 'spec_helper'

describe "internet_var.rb" do
  let!(:good_transaction) { FactoryGirl.create(:good_transaction,
                                               ip: "8.8.8.8",
                                               name: "Jonathan Somebody Jr.",
                                               email: "somebody.jon@gmail.gov") }

  let!(:bad_transaction1) { FactoryGirl.create(:bad_transaction,
                                              ip: "8.8.8.8",
                                              email: "GlobalGasCard@yahoo.com",
                                              name: "Jonathan Nobody Jr.") }

  let!(:bad_transaction2) { FactoryGirl.create(:bad_transaction,
                                              email: "hello@hotstuff.com",
                                              ip: "192.168.0.1") }

  let!(:bad_email) { FactoryGirl.create(:good_transaction,
                                       name: "Period",
                                       email: "no_at_or_period") }

  let!(:nil_transaction) { FactoryGirl.create(:good_transaction,
                                              email: nil,
                                              ip: nil) }

  before :each do
    Util::IP.seed_public_computers(Transaction.find_public_ips)
  end

  describe "explanatory_variable email_match" do
    it "should return true if email matches name, and false if email does not match name" do
      var = ExplanatoryVariable.lookup(:email_match)
      var.evaluate(good_transaction).should be_true
      var.evaluate(bad_transaction1).should be_false
      var.evaluate(bad_email).should be_true
      var.evaluate(nil_transaction).should be_nil
    end
  end

  describe "explanatory_variable domain_type" do
    it "should return type of email domain" do
      var = ExplanatoryVariable.lookup(:domain_type)
      var.evaluate(good_transaction).should == :protected
      var.evaluate(bad_transaction1).should == :free
      var.evaluate(bad_transaction2).should == :unknown
      var.evaluate(bad_email).should be_nil
    end
  end

  describe "explanatory_variable ip_exists" do
    it "should return true if IP is in database, and false otherwise" do
      var = ExplanatoryVariable.lookup(:ip_exists)
      var.evaluate(good_transaction).should == true
      var.evaluate(bad_transaction2).should == false
      var.evaluate(nil_transaction).should be_nil
    end
  end

  describe "explanatory_variable public_ip" do
    it "should return true for a public IP and false for a not public one" do
      var = ExplanatoryVariable.lookup(:public_ip)
      var.evaluate(bad_transaction2).should == false
      var.evaluate(bad_transaction1).should == true
      var.evaluate(nil_transaction).should be_nil
    end
  end

  describe "explanatory_variable network" do
    it "should return the owner of the network containing a the transaction's address" do
      var = ExplanatoryVariable.lookup(:network)
      var.evaluate(good_transaction).should include "LVLT"
      var.evaluate(nil_transaction).should be_nil
    end
  end

  describe "explanatory_variable address_class" do
    it "should return the class of the transaction's IP address" do
      var = ExplanatoryVariable.lookup(:address_class)
      var.evaluate(good_transaction).should == :A
      var.evaluate(nil_transaction).should be_nil
    end
  end

  describe "explanatory_variable network_owner_type" do
    it "should return the network owner type of the transaction's IP address" do
      var = ExplanatoryVariable.lookup(:network_owner_type)
      var.evaluate(good_transaction).should == :unknown
    end
  end

  describe "explanatory_variable currency_match" do
    let(:var) { ExplanatoryVariable.lookup(:currency_match) }

    it "should return true if currency matches with country" do
      transaction = create(:transaction, :other_data => {"account_country"=>"us", "denomination" => "USD"})
      var.evaluate(transaction).should == true
    end

    it "should return false if currency doesn't match with country" do
      transaction = create(:transaction, :other_data => {"account_country"=>"gb", "denomination" => "USD"})
      var.evaluate(transaction).should == false
    end

    it "should return false if country is invalid" do
      transaction = create(:transaction, :other_data => {"account_country"=>"gb1", "denomination" => "USD"})
      var.evaluate(transaction).should == false
    end

    it "should return nil if country is missing" do
      transaction = create(:transaction, :other_data => {"denomination" => "USD"})
      var.evaluate(transaction).should == nil
    end

    it "should return nil if currency is missing" do
      transaction = create(:transaction, :other_data => {"account_country"=>"gb"})
      var.evaluate(transaction).should == nil
    end

    it "should base on shipping_country if account_country isn't available" do
      transaction = create(:transaction, :shipping_country => "US", :other_data => {"denomination" => "USD"})
      var.evaluate(transaction).should == true
    end
  end
end
