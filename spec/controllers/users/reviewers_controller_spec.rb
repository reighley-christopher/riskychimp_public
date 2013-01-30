require 'spec_helper'

describe Users::ReviewersController do
  context "unauthenticated" do
    it "should redirect to root path" do
      get :index, user_id: 1
      response.should redirect_to(new_user_session_path)
    end
  end

  context "authenticated" do
    let(:merchant) { create(:merchant) }
    let(:reviewer) { create(:reviewer, merchant: merchant) }
    before do
      sign_in merchant
    end
    describe "GET 'index'" do
      it "should list all reviewers" do
        reviewer1 = create(:reviewer, merchant: merchant)
        reviewer2 = create(:reviewer, merchant: merchant)
        get :index, user_id: merchant
        response.should be_success
        assigns(:reviewers).should =~ [reviewer1, reviewer2]
      end
    end

    describe "GET 'show'" do
      context "with valid param" do
        it "should be success" do
          get :show, id: reviewer, user_id: merchant
          response.should be_success
          assigns(:reviewer).should == reviewer
        end
      end

      context "with invalid param" do
        it "should redirect to index page" do
          get :show, id: 'something', user_id: merchant
          response.should redirect_to(user_reviewers_path(user_id: merchant))
        end
      end
    end

    describe "GET 'edit'" do
      it "should be success" do
        get :edit, id: reviewer, user_id: merchant
        response.should be_success
        assigns(:reviewer).should == reviewer
      end
    end

    describe "PUT 'update'" do
      context "with valid param" do
        it "should be success" do
          put :update, id: reviewer, user: { email: 'new_email@test.com' }, user_id: merchant
          response.should redirect_to(user_reviewer_path(reviewer, user_id: merchant))
        end
      end

      context "with invalid param" do
        it "should not update user" do
          put :update, id: reviewer, user: { email: '' }, user_id: merchant
          response.should be_success
          response.should render_template('edit')
          assigns(:reviewer).should have(1).errors_on(:email)
          assigns(:reviewer).errors[:email].should == ["can't be blank"]
        end
      end
    end

    describe "GET 'new'" do
      it "should be success" do
        get :new, user_id: merchant
        response.should be_success
        assigns(:reviewer).should be_new_record
        assigns(:reviewer).should be_reviewer
      end
    end

    describe "POST 'create'" do
      context 'with valid params' do
        it "should be success" do
          post :create, user: { email: 'new_email@test.com' }, user_id: merchant
          User.find_by_email("new_email@test.com").should be_reviewer
          response.should redirect_to(user_reviewers_path(user_id: merchant))
          flash[:notice].should == I18n.t("reviewers.invited")
        end
      end

      context "with invalid params" do
        it "should not create user" do
          param_email = reviewer.email
          lambda {
            post :create, user: { email: param_email }, user_id: merchant
            response.should render_template('new')
            assigns(:reviewer).should have(1).errors_on(:email)
            assigns(:reviewer).errors[:email].should == ["has already been taken"]
          }.should_not change(User, :count)
        end
      end
    end

    describe "DELETE 'destroy'" do
      it "should be success" do
        delete :destroy, id: reviewer, user_id: merchant
        response.should redirect_to(user_reviewers_path(user_id: merchant))
        User.should_not be_exists(reviewer)
      end
    end
  end

  context "authenticated as admin" do
    let(:admin) { create(:admin) }
    let(:reviewer) { create(:reviewer) }
    before do
      sign_in admin
    end

    describe "GET 'show'" do
      it "should be success" do
        get :show, id: reviewer, user_id: reviewer.merchant
        response.should be_success
      end
    end
  end
end