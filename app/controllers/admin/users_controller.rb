class Admin::UsersController < Admin::AdminController
  before_filter :find_user, :only => [:show, :edit, :update, :destroy, :invite, :login]
  def index
    params[:role] ||= 'merchant'
    @users = User.list_of(params[:role]).paginate(page: current_page)
  end

  def show
  end

  def edit
  end

  def update
    merchant = User.merchants.where(id: params[:user].delete(:merchant_id)).first
    role_title = params[:user].delete(:role)
    if role_title == User::Roles[:reviewer]
      if merchant
        @user.merchant = merchant
      end
    end
    if @user.update_attributes(params[:user])
      @user.add_role(role_title)
      redirect_to admin_user_path(@user), notice: t("admin.users.updated")
    else
      render 'edit'
    end
  end

  def new
    @user = User.new
    @user.role = params[:role].to_s.downcase
  end

  def create
    @user = User.new(email: params[:user][:email])
    if @user.valid_attribute?(:email)
      @user = User.invite!(email: params[:user][:email])
      @user.add_role(params[:user][:role])
      redirect_to admin_users_path(role: @user.role), notice: t("admin.users.invited")
    else
      render 'new'
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path(role: @user.role)
  end

  def invite
    if @user.invitation_accepted_at
      flash[:notice] = t("admin.users.invitation.already")
    elsif @user.invitation_sent_at
      @user.invite!
      flash[:notice] = t("admin.users.invited")
    else
      flash[:notice] = t("admin.users.invitation.not_invited")
    end
    redirect_to admin_users_path(role: 'Pending')
  end

  def login
    sign_in @user, :bypass => true
    redirect_to refinery.root_path
  end

  private
  def find_user
    unless @user = User.find_by_id(params[:id])
      redirect_to admin_users_path, error: t("admin.users.access.denied")
    end
  end
end
