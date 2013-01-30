require 'spec_helper'

describe NotesController do
  render_views

  describe "authentications" do
    it "should require login" do
      transaction = create(:transaction)
      post :create, transaction_id: transaction
      response.should redirect_to(new_user_session_path)
    end

    it "should require current user to be able to access to transaction" do
      transaction = create(:transaction)
      note = create(:note, transaction: transaction)
      user = create(:user)
      sign_in user
      put :update, id: note, transaction_id: transaction
      response.should redirect_to(transactions_path)
      flash[:error].should == I18n.t("transactions.access.denied")
    end
  end

  describe "authenticated" do
    let(:user) { create(:user) }
    let(:transaction) { create(:transaction, user: user) }
    before do
      sign_in user
    end

    describe "POST 'create'" do
      context "with valid params" do
        it "should be success" do
          lambda {
            post :create, transaction_id: transaction, note: { content: "something" }, format: :js
          }.should change(Note, :count).by(1)

          response.should be_success
          response.body.should include(I18n.t("transactions.notes.created"))
          transaction.reload.note.content.should == "something"
        end
      end

      context "with invalid params" do
        it "should show error message" do
          lambda {
            post :create, transaction_id: transaction, note: { content: "" }, format: :js
          }.should_not change(Note, :count)
          response.should be_success
          assigns(:note).should have(1).errors_on(:content)
          assigns(:note).errors[:content].should == ["can't be blank"]
        end
      end

      context "with html format" do
        it "should redirect to transaction show page" do
          post :create, transaction_id: transaction
          response.should redirect_to(transaction_path(transaction))
        end
      end
    end

    describe "PUT 'update'" do
      let(:note) { create(:note, transaction: transaction, content: "note content") }
      context "with valid params" do
        it "should be success" do
          put :update, transaction_id: transaction, id: note, note: { content: "something new" }, format: :js
          note.reload.content.should == "something new"
          response.body.should include(I18n.t("transactions.notes.updated"))
          response.should be_success
        end
      end

      context "with invalid params" do
        it "should not update note" do
          put :update, transaction_id: transaction, id: note, note: { content: "" }, format: :js
          note.reload.content.should == "note content"
          response.should be_success
          assigns(:note).should have(1).errors_on(:content)
          assigns(:note).errors[:content].should == ["can't be blank"]
        end
      end

      context "with html format" do
        it "should redirect to transaction show page" do
          put :update, transaction_id: transaction, id: note
          response.should redirect_to(transaction_path(transaction))
        end
      end
    end
  end
end
