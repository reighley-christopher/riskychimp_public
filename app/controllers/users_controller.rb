class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:report_error]
  before_filter :find_user, :only => [:show, :edit, :update, :change_password, :setting, :update_setting, :update_model_params]

  def show
    @sender = AppSetting.find_or_create_by_key(AppSetting::SENDER)
    @sender.update_attribute(:value, current_user.email) unless @sender.value
  end

  def edit
  end

  def update
    params[:user].delete(:password)
    params[:user].delete(:password_confirmation)
    changing_email = params[:user][:email] != @user.email
    if @user.update_attributes(params[:user])
      flash[:notice] = (changing_email && @user.pending_reconfirmation?) ?
          t("devise.confirmations.resend_instructions") :
          t("users.information.updated")
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def change_password
    if request.put? && params[:user]
      if @user.valid_password?(params[:user][:current_password])
        if @user.update_attributes(params[:user].slice(:password, :password_confirmation))
          flash[:notice] = t('users.password.updated')
          sign_in(@user, :bypass => true)
          redirect_to user_path(@user)
        end
      else
        @user.errors.add(:base, t('users.password.current.invalid'))
      end
    end
  end

  def setting
    @user.user_setting ||= UserSetting.create(user: @user, amount_threshold: 0)
  end

  def update_setting
    str = @user.user_setting.set_model_parameters(params) if @user.merchant?
    if @user.user_setting.update_attributes(params[:user_setting].merge({ "model_params" => str }))
      redirect_to user_path(@user), notice: t('users.setting.updated')
    else
      render :action => 'setting'
    end
  end

  def report_error
    if params[:invitation_token] && user = User.where(:invitation_token => params[:invitation_token]).first
      user.update_attribute(:error_invited, true)
    end

    redirect_to refinery.root_path, notice: t("users.invitations.report_error")
  end

  private
  def find_user
    @user = User.find_by_id(params[:id])
    unless @user && @user == current_user
      redirect_to refinery.root_path, error: t('users.access.denied')
    end
  end
end
