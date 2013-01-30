require 'spec_helper'

describe Transaction do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_one(:note) }
  end

  describe "#self.find_public_ips" do
    it "should find an IP used by two different people" do
      ip1 = "192.168.0.1"
      ip2 = "192.168.0.2"
      email = "jsomebody@example.com"
      another_email = "js@example.com"
      create(:transaction, ip: ip1, email: email)
      create(:transaction, ip: ip1, email: email)
      create(:transaction, ip: ip2, email: another_email)
      create(:transaction, ip: ip2, email: email)

      enumerable = Transaction.find_public_ips
      enumerable.should include(ip2)
      enumerable.should_not include(ip1)
    end
  end

  describe "date_from" do
    before :each do
      create(:transaction, transaction_datetime: DateTime.parse('2012-01-01 14:00 +00:00'))
      create(:transaction, transaction_datetime: DateTime.parse('2012-01-01 21:00 +00:00'))
    end

    it "should find transactions after the given datetime" do
      Transaction.date_from(DateTime.parse('2010-05-05 05:05 -07:00')).count.should == 2
      Transaction.date_from(DateTime.parse('2012-01-01 13:45 -07:00')).count.should == 1
      Transaction.date_from(DateTime.parse('2012-01-01 14:45 -07:00')).count.should == 0
    end

    it "should raise an error if the given parameter is not a datetime" do
      expect {
        Transaction.date_from('2012-01-01 13:45 -0700')
      }.to raise_exception
    end
  end

  describe "calculate_score" do
    it "should calculate the score of transaction and update to instance" do
      user = create(:merchant)
      transaction = create(:transaction, user: user)
      transaction.score.should be_nil
      transaction.calculate_score!
      transaction.reload.score.should_not be_nil
      (0..100).should cover(transaction.score)
    end

    it "should give the same score if nothing has changed, and " +
           "a different score when parameter weights have been changed" do
      merchant = create(:merchant)
      transaction = create(:good_transaction, user: merchant, amount: 50)
      other_transaction = create(:good_transaction, user: merchant, amount: 20 )
      yet_another_transaction = create(:good_transaction, user: merchant, amount: 700)
      params1 = merchant.user_setting.adjustable_model_parameters.merge(amount: 1)
      params2 = merchant.user_setting.adjustable_model_parameters.merge(amount: 4)

      merchant.user_setting.set_model_parameters(params1)
      score1 = transaction.calculate_score!

      merchant.user_setting.set_model_parameters(params2)
      score2 = transaction.calculate_score!

      merchant.user_setting.set_model_parameters(params1)
      score1_again = transaction.calculate_score!

      score2.should_not == score1
      score1_again.should == score1
    end
  end

  describe "other_data" do
    let(:test_value) { "test_value" }
    let(:other_test_key) { 1 }
    let(:other_test_number) { 10 }
    let(:trans) { create(:transaction, other_data: { test_key: test_value }) }
    let(:trans_with_json) { create(:transaction, other_data: "{\"test_key\":\"#{other_test_key}\", \"test_number\":#{other_test_number}}") }
    let(:trans_with_yaml) { create(:transaction, other_data: "---\ntest_key: '#{other_test_key}'\ntest_number: #{other_test_number}\n") }
    let(:dirty_trans) { create(:transaction, other_data: "this is unclean data") }
    let(:sparse_trans) { create(:transaction) }

    it "should not destroy other data because I added something to it" do
      trans.other_data[:new_key] = "new stuff"
      trans.other_data[:test_key].should == test_value
    end

    it "should react to changes to the hash that it has saved" do
      changed_value = "changed_value"
      trans.other_data.class.should == ActiveSupport::HashWithIndifferentAccess
      trans.reload
      trans.other_data.should_not be_nil
      trans.other_data.class.should == ActiveSupport::HashWithIndifferentAccess
      trans.other_data[:test_key].should == test_value
      trans.other_data[:test_key] = changed_value
      trans.reload.other_data[:test_key].should == changed_value
    end

    it "should forget old other_data when old other_data is overwritten" do
      new_data = "new_stuff"
      od_1 = trans.other_data
      trans.other_data = {new_stuff: new_data}
      od_1[:new_stuff] = "this is a NoOp"
      trans.other_data[:new_stuff].should == new_data
    end

    it "two callers using other data at the same time should share it" do
      new_value = new_value
      od_1 = trans.other_data
      od_2 = trans.other_data
      od_2[:test_key].should == test_value
      od_1[:test_key] = new_value
      od_2[:test_key].should == new_value
    end

    it "should correctly cast JSON" do
      trans_with_json.other_data.class.should == ActiveSupport::HashWithIndifferentAccess
      trans_with_json.other_data[:test_key].should == other_test_key.to_s
      trans_with_json.other_data[:test_number].should == other_test_number
      trans_with_json.reload.other_data[:test_key].should == other_test_key.to_s
      trans_with_json.other_data[:test_number].should == other_test_number
    end

    it "should correctly cast YAML" do
      trans_with_yaml.other_data.class.should == ActiveSupport::HashWithIndifferentAccess
      trans_with_yaml.other_data[:test_key].should == other_test_key.to_s
      trans_with_yaml.other_data[:test_number].should == other_test_number
      trans_with_yaml.reload.other_data[:test_key].should == other_test_key.to_s
      trans_with_yaml.other_data[:test_number].should == other_test_number
    end

    it "should form hash of something that cannot be correctly cast so that we never throw away data" do
      unclear_data = "this is unclean data"
      dirty_trans.other_data.class.should == ActiveSupport::HashWithIndifferentAccess
      dirty_trans.other_data[""].should == unclear_data
      dirty_trans.reload.other_data[""].should == unclear_data
    end

    it "should return a blank-nil HashWithIndifferentAccess if other_data has not been set" do
      sparse_trans.other_data.should == { "" => nil }.with_indifferent_access
    end

    it "should return a blank-nil HashWithIndifferentAccess if we set other_data with a nil" do
      dirty_trans.other_data.should_not == { "" => nil }.with_indifferent_access
      dirty_trans.other_data = nil
      dirty_trans.other_data.should == { "" => nil }.with_indifferent_access
    end
  end

  describe "related_notes" do
    it "should not include the note of the transaction" do
      transaction = create(:transaction)
      note = create(:note, transaction: transaction)
      transaction.related_notes.should_not include(note)
    end

    it "should not include the note of the transaction from other user" do
      transaction = create(:transaction, purchaser_id: 'purchaser_1')
      note = create(:note, transaction: transaction)

      other_transaction = create(:transaction, purchaser_id: 'purchaser_1')
      other_note = create(:note, transaction: other_transaction)
      transaction.related_notes.should_not include(other_note)
    end

    context "when having a note of a transaction with purchaser_id" do
      it "should share in other transaction with the same purchaser_id" do
        purchase_id = 'purchaser_1'
        transaction = create(:transaction, purchaser_id: purchase_id)
        note = create(:note, transaction: transaction)
        new_transaction = create(:transaction, purchaser_id: purchase_id, user: transaction.user)
        new_transaction.related_notes.should == [note]
      end
    end

    context "when having a note of a transaction without purchaser_id" do
      context "but has device_id" do
        it "should share in other transaction with the same device_id" do
          @device_id = 'device_1'
          transaction = create(:transaction, device_id: @device_id)
          note = create(:note, transaction: transaction)
          new_transaction = create(:transaction, device_id: @device_id, user: transaction.user)
          new_transaction.related_notes.should == [note]
        end

        it "should not share with other transaction with different device_id" do
          @another_device_id = 'device_2'
          transaction = create(:transaction, device_id: @device_id)
          create(:note, transaction: transaction)
          new_transaction = create(:transaction, device_id: @another_device_id, user: transaction.user)
          new_transaction.related_notes.should be_empty
        end
      end

      context "and has no device_id" do
        it "should not share to other transaction" do
          transaction = create(:transaction)
          create(:note, transaction: transaction)
          new_transaction = create(:transaction, user: transaction.user)
          new_transaction.related_notes.should be_empty
        end
      end
    end
  end

  describe "reviewer" do
    context "when status is pending" do
      it "should be nil" do
        user = create(:user)
        PaperTrail.whodunnit = user.id
        transaction = create(:transaction)
        transaction.approve!
        transaction.reset!
        transaction.reviewer.should be_nil
      end
    end

    context "when status is not pending" do
      context "when having versions" do
        it "should return the last version's whodunnit" do
          user = create(:user)
          PaperTrail.whodunnit = user.id
          transaction = create(:transaction)
          transaction.approve!
          transaction.reviewer.should == user
        end
      end

      context "when having no version" do
        it "should return nil" do
          transaction = create(:transaction, status: 'approved')
          transaction.reviewer.should be_nil
        end
      end
    end
  end
end

