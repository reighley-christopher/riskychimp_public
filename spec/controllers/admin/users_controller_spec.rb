require 'spec_helper'

describe Admin::UsersController do
  context "unauthenticated" do
    it "should redirect to root path" do
      get :index
      response.should redirect_to('/')
      flash[:notice].should == I18n.t("users.access.denied")
    end
  end

  context "authenticated" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user) }
    before do
      sign_in admin
    end
    describe "GET 'index'" do
      it "should be success" do
        get :index
        response.should be_success
      end

      it "should list all merchants" do
        merchant1 = create(:merchant)
        merchant2 = create(:merchant)
        get :index
        response.should be_success
        assigns(:users).should =~ [merchant1, merchant2]
      end

      it "should list users based on role param" do
        get :index, role: 'admin'
        response.should be_success
        assigns(:users).should == [admin]
      end
    end

    describe "GET 'show'" do
      context "with valid param" do
        it "should be success" do
          get :show, id: user
          response.should be_success
          assigns(:user).should == user
        end
      end

      context "with invalid param" do
        it "should redirect to index page" do
          get :show, id: 'something'
          response.should redirect_to(admin_users_path)
        end
      end
    end

    describe "GET 'edit'" do
      it "should be success" do
        get :edit, id: user
        response.should be_success
        assigns(:user).should == user
      end
    end

    describe "PUT 'update'" do
      context "with valid param" do
        it "should be success" do
          put :update, id: user, user: { email: 'new_email@test.com', role: "Admin" }
          response.should redirect_to(admin_user_path(user))
        end
      end

      context "with invalid param" do
        it "should not update user" do
          put :update, id: user, user: { email: '' }
          response.should be_success
          response.should render_template('edit')
          assigns(:user).should have(1).errors_on(:email)
        end
      end
    end

    describe "GET 'new'" do
      it "should be success" do
        get :new, role: 'admin'
        response.should be_success
        assigns(:user).should be_new_record
        assigns(:user).should be_admin
      end
    end

    describe "POST 'create'" do
      context 'with valid params' do
        it "should be success" do
          post :create, user: { email: 'new_email@test.com', role: 'admin' }
          User.find_by_email("new_email@test.com").should be_admin
          response.should redirect_to(admin_users_path(:role => 'admin'))
          flash[:notice].should == I18n.t("admin.users.invited")
        end
      end

      context "with invalid params" do
        it "should not create user" do
          lambda {
            post :create, user: {}
            response.should render_template('new')
          }.should_not change(User, :count)
        end
      end
    end

    describe "DELETE 'destroy'" do
      it "should be success" do
        delete :destroy, id: user
        response.should redirect_to(admin_users_path)
        User.should_not be_exists(user)
      end
    end

    describe "GET 'invite'" do
      context "with unaccepted user" do
        it "should send invitation email to user" do
          user = User.invite!(email: "new_email@test.com")
          lambda {
            get :invite, id: user
            response.should redirect_to(admin_users_path(role: "Pending"))
          }.should change(ActionMailer::Base.deliveries, :count).by(1)
          email = ActionMailer::Base.deliveries.last
          email.to.should == ["new_email@test.com"]
        end
      end

      context "with accepted user" do
        it "should not send invitation email" do
          user = create(:user, invitation_sent_at: Time.now, invitation_accepted_at: Time.now)
          lambda {
            get :invite, id: user
            response.should redirect_to(admin_users_path(role: "Pending"))
            flash[:notice].should == I18n.t("admin.users.invitation.already")
          }.should_not change(ActionMailer::Base.deliveries, :count)
        end
      end

      context "with non-invited user" do
        it "should not send invitation email" do
          user = create(:user)
          lambda {
            get :invite, id: user
            response.should redirect_to(admin_users_path(role: "Pending"))
            flash[:notice].should == I18n.t("admin.users.invitation.not_invited")
          }.should_not change(ActionMailer::Base.deliveries, :count)
        end
      end
    end

    describe "POST 'login'" do
      it "should redirect to root path" do
        user = create(:user)
        post :login, id: user
        response.should redirect_to('/')
      end
    end
  end
end
