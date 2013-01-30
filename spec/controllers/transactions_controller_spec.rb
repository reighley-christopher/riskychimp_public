require 'spec_helper'

describe TransactionsController do
  render_views

  describe "authentication" do
    it "should require login" do
      get :index
      response.should redirect_to(new_user_session_path)
    end

    it "should require current user to be able to access to transaction" do
      transaction = create(:transaction)
      user = create(:user)
      sign_in user
      get :show, id: transaction
      response.should redirect_to(transactions_path)
      flash[:error].should == I18n.t("transactions.access.denied")
    end
  end

  describe "authenticated" do
    let!(:user) { create(:user) }
    let!(:merchant) { create(:merchant) }
    let(:transaction) { create(:transaction, user: user) }

    before do
      sign_in user
    end

    describe "GET 'index'" do
      before do
        @transaction1 = create(:transaction, :user => user, :amount => "10.0", :transaction_id => "123")
        @transaction2 = create(:transaction, :user => create(:user), :amount => "5.2", :transaction_id => "125")
        @transaction3 = create(:transaction, :user => user, :amount => "20.1", :transaction_id => "234")
        @merchant_transaction1 = create(:transaction, :user => merchant, :amount => "100.0", :transaction_id => "345")
        @merchant_transaction2 = create(:transaction, :user => merchant, :amount => "90.0", :transaction_id => "456")
      end

      it "should show all transactions of current user" do
        get :index
        response.should be_success
        assigns(:transactions).should =~ [@transaction1, @transaction3]
        response.body.should include("Transaction ID")
        response.body.should include("123")
        response.body.should include("234")
        response.body.should_not include("125")
        response.body.should include("Amount")
        response.body.should include("10.0")
        response.body.should include("20.1")
        response.body.should_not include("5.2")
      end

      it "should show all transactions that have the amount greater than or equal to the user setting's amount threshold" do
        user.reload.user_setting.update_attribute(:amount_threshold, 20)
        get :index
        response.should be_success
        assigns(:transactions).should == [@transaction3]
      end

      it "should show all transaction of specific merchant" do
        admin = create(:admin)
        sign_in admin
        get :index, user_id: merchant.id
        assigns(:transactions).should == [@merchant_transaction1, @merchant_transaction2]
      end

      it "should not show all transaction of specific merchant if current user is not an admin" do
        get :index, user_id: merchant.id
        assigns(:transactions).should == [@transaction1, @transaction3]
      end
    end

    describe "GET 'show'" do
      it "should be success with valid id" do
        get :show, id: transaction
        response.should be_success
        assigns(:transaction).should == transaction
      end

      context "with existing note" do
        it "should load note" do
          note = create(:note, transaction: transaction)
          get :show, id: transaction
          response.should be_success
          assigns(:note).should == note
        end
      end

      context "with no note" do
        it "should build a new note" do
          get :show, id: transaction
          response.should be_success
          assigns(:note).should be_new_record
          assigns(:note).transaction.should == transaction
        end
      end
    end

    describe "PUT 'change_status'" do
      context "with valid param" do
        it "should be success" do
          put :change_status, id: transaction, status: 'approve', format: :js
          response.should be_success
          transaction.reload.should be_approved
        end
      end

      context "with invalid param" do
        it "should do nothing" do
          put :change_status, id: transaction, status: 'something', format: :js
          response.should be_success
          transaction.reload.should be_pending
        end
      end

      context "with 'reset' status" do
        describe "when current user is merchant" do
          it "should change status" do
            merchant = create(:merchant)
            sign_in merchant
            put :change_status, id: transaction, status: 'reset', format: :js
            response.should be_success
            transaction.reload.should be_pending
          end
        end

        describe "when current user is admin" do
          it "should change status" do
            admin = create(:admin)
            sign_in admin
            put :change_status, id: transaction, status: 'reset', format: :js
            response.should be_success
            transaction.reload.should be_pending
          end
        end

        describe "when current user is reviewer" do
          it "should not change status" do
            reviewer = create(:reviewer)
            sign_in reviewer
            transaction.approve!
            put :change_status, id: transaction, status: 'reset', format: :js
            response.should be_success
            transaction.reload.should be_approved
          end
        end
      end
    end

    describe "PUT 'update_amount_threshold'" do
      before do
        @transaction1 = create(:transaction, :user => user, :amount => "10.0", :transaction_id => "123")
        @transaction2 = create(:transaction, :user => create(:user), :amount => "5.2", :transaction_id => "125")
        @transaction3 = create(:transaction, :user => user, :amount => "20.1", :transaction_id => "234")
      end

      context "with valid param" do
        it 'should redirect to index page' do
          put :update_amount_threshold, user_setting: { amount_threshold: 8 }
          response.should redirect_to(transactions_path(user_id: user))
          user.reload.user_setting.amount_threshold.should == 8
        end
      end

      context "with invalid param" do
        it "should render error" do
          put :update_amount_threshold, user_setting: { amount_threshold: 'something' }
          response.should be_success
          response.body.should include('Amount threshold is not a number')
        end
      end
    end

    describe "GET 'email_detail'" do
      it "should be success" do
        get :email_detail, id: transaction, format: :js
        response.should be_success
        assigns(:transactions).should include(transaction)
      end
    end
  end
end
