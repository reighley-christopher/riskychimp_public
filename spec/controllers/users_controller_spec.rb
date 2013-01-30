require 'spec_helper'

describe UsersController do
  let!(:user) { create(:user) }
  before do
    sign_in user
  end

  describe "GET 'show'" do
    describe "with current user id" do
      it "should be success" do
        get :show, :id => user
        response.should be_success
        assigns(:user).should == user
      end
    end
  end

  describe "GET 'edit'" do
    describe "with current user id" do
      it "should be success" do
        get :edit, :id => user
        response.should be_success
        assigns(:user).should == user
      end
    end
  end

  describe "PUT 'update'" do
    context "with current user id" do
      describe "with valid params" do
        it "should update successfully" do
          put :update, id: user, user: { company_name: "another_company", company_website:"another.com" }
          response.should redirect_to(user_path(user))
          user.reload.company_name.should == "another_company"
          user.company_website.should == "another.com"
        end
      end

      describe "with invalid params" do
        it "should raise error" do
          put :update, id: user, user: { email: "" }
          response.should be_success
          response.should render_template('edit')
          assigns(:user).errors_on(:email).should == ["can't be blank"]
        end
      end

      describe "when changing email" do
        it "should send a confirmation email to old email address" do
          old_email = user.email
          put :update, id: user, user: { email: "another@gmail.com", company_name: "another company" }
          response.should redirect_to(user_path(user))
          flash[:notice].should == I18n.t("devise.confirmations.resend_instructions")
          user.reload.company_name.should == "another company"
          user.email.should == old_email
          user.unconfirmed_email.should == "another@gmail.com"
          mail = ActionMailer::Base.deliveries.last
          mail.to.should include("another@gmail.com")
          mail.subject.should == "Confirmation instructions"
        end
      end
    end
  end

  describe "change_password" do
    render_views
    describe "with GET method" do
      it "should load the 'change password' form" do
        get :change_password, id: user
        response.should be_success
        response.body.should include("Current password")
        response.body.should include("New password")
        response.body.should include("New password confirmation")
      end
    end

    describe "with PUT method" do
      context "when having invalid old password" do
        it "should not update new password" do
          put :change_password, id: user, user: { current_password: 'something else', password: 'new_pass', password_confirmation: 'new_pass' }
          response.should be_success
          response.body.should include(I18n.t('users.password.current.invalid'))
          user.reload.should_not be_valid_password('new_pass')
        end
      end

      context "when having invalid password confirmation" do
        it "should not update new password" do
          put :change_password, id: user, user: { current_password: 'secret', password: 'new_pass', password_confirmation: 'new' }
          response.should be_success
          response.body.should include("Password doesn't match confirmation")
          user.reload.should be_valid_password('secret')
        end
      end

      context "when having valid params" do
        it "should update new password" do
          put :change_password, id: user, user: { current_password: 'secret', password: 'new_pass', password_confirmation: 'new_pass' }
          response.should redirect_to(user_path(user))
          flash[:notice].should == I18n.t('users.password.updated')
          user.reload.should be_valid_password('new_pass')
        end
      end
    end
  end

  describe "GET 'setting'" do
    it "should be success" do
      get :setting, id: user
      response.should be_success
    end
  end

  describe "PUT 'update_setting'" do
    context "with valid params" do
      it "should update attributes" do
        put :update_setting, id: user, user_setting: {amount_threshold: 100 , time_zone: "Eastern Time (US & Canada)"}
        response.should redirect_to(user_path(user))
        flash[:notice].should == I18n.t('users.setting.updated')
        user.reload.user_setting.amount_threshold.should == 100
        user.time_zone.should == "Eastern Time (US & Canada)"
      end
    end

    context "with invalid params" do
      it "should not update attributes" do
        put :update_setting, id: user, user_setting: {amount_threshold: -1}
        response.should render_template('setting')
        user.reload.user_setting.amount_threshold.should == 0
      end
    end
  end
end
