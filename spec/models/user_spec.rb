require 'spec_helper'

describe User do
  describe "associations" do
    it { should have_many(:transactions) }
    it { should have_many(:reviewers) }
    it { should have_one(:user_setting) }
    it { should belong_to(:merchant) }
  end

  describe "validations" do
    it { should validate_acceptance_of(:terms) }
  end

  describe "#api key" do
    it "should create a unique api key for new user" do
      user = create(:user)
      user.api_key.should_not be_nil

      new_user = create(:user)
      new_user.api_key.should_not == user.api_key
    end
  end

  describe "#has_role?" do
    it "should return false if user has no role" do
      user = create(:user)
      user.has_role?(:admin).should be_false
    end

    it "should return true if user's role is matched" do
      user = create(:admin)
      user.has_role?(:admin).should be_true
      user.has_role?(:merchant).should be_false
    end
  end

  describe "#add_role" do
    context "with existing role" do
      it "should set new role" do
        user = create(:user)
        user.add_role('admin')
        user.reload.should be_admin
      end
    end

    context "with non-existing role" do
      it "should not set new role" do
        user = create(:admin)
        user.add_role('new')
        user.reload.should be_admin
      end
    end

    context "with 'admin' role" do
      it "should add all refinery plugins for admin" do
        user = create(:user)
        user.add_role(:admin)
        user.plugins.map(&:name).should == Refinery::Plugins.registered.in_menu.names
      end
    end
  end

  describe "#can_access?" do
    let(:user) { create(:user) }
    context "user is admin" do
      it "should be true" do
        admin = create(:admin)
        admin.can_access?(user).should be_true
      end
    end

    context "user access self" do
      it "should be true" do
        user.can_access?(user).should be_true
      end
    end

    context "user is not admin and not access self" do
      it "should be false" do
        other_user = create(:user)
        user.can_access?(other_user).should be_false
      end
    end
  end

  describe "#related_transactions" do
    before do
      @merchant = create(:merchant)
      @transaction1 = create(:transaction, user: @merchant)
      @transaction2 = create(:transaction, user: @merchant)
      @transaction3 = create(:transaction)
    end

    context "when user is admin" do
      it "should load all transactions" do
        admin = create(:admin)
        admin.related_transactions.should =~ [@transaction1, @transaction2, @transaction3]
      end
    end

    context "when user is merchant" do
      it "should load all transactions belong to user" do
        @merchant.related_transactions.should =~ [@transaction1, @transaction2]
      end
    end

    context "when user is reviewer" do
      it "should load all transactions belong to user's merchant" do
        reviewer = create(:reviewer, merchant: @merchant)
        reviewer.related_transactions.should =~ [@transaction1, @transaction2]

        other_reviewer = create(:reviewer)
        other_reviewer.related_transactions.should be_empty
      end
    end
  end

  describe "#list_of" do
    context "title is 'pending'" do
      it "should return list of pending invitation users" do
        User.should_receive(:invitation_not_accepted)
        User.list_of('Pending')
      end
    end

    context "title is 'error'" do
      it "should return list of error users" do
        user1 = create(:user)
        user2 = create(:user, error_invited: true)
        User.list_of('Error').should == [user2]
      end
    end

    context "title is one of user's role" do
      it "should return the list of users based on role" do
        User.should_receive(:merchants)
        User.list_of('merchant')
      end
    end
  end

  describe "#fraud_model" do
    before do
      @merchant = create(:merchant)
      @the_same_merchant = User.find(@merchant.id)
    end

    it "should return a fraud_model, and only create a fraud_model the first time" do
      @merchant.fraud_model.class.should == FraudModel
      @the_same_merchant.fraud_model.should == @merchant.fraud_model
    end

    it "should return the fraud_model of the merchant" do
      reviewer = create(:reviewer, merchant: @merchant)
      reviewer.fraud_model.should == @merchant.fraud_model
    end
  end
end