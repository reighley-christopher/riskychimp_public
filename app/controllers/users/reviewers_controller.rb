class Users::ReviewersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_merchant
  before_filter :find_reviewer, :only => [:show, :edit, :update, :destroy]

  def index
    @reviewers = @merchant.reviewers.paginate(page: current_page)
  end

  def show
  end

  def new
    @reviewer = @merchant.reviewers.new
    @reviewer.role = User::Roles[:reviewer]
  end

  def edit
  end

  def create
    @reviewer = User.new(params[:user])
    if @reviewer.valid_attribute?(:email)
      @reviewer = User.invite!(params[:user].merge(merchant: @merchant))
      @reviewer.add_role(User::Roles[:reviewer])
      redirect_to user_reviewers_path(user_id: @merchant.id), notice: t("reviewers.invited")
    else
      render 'new'
    end
  end

  def update
    if @reviewer.update_attributes(params[:user])
      redirect_to user_reviewer_path(@reviewer, user_id: @merchant), notice: t("reviewers.updated")
    else
      render 'edit'
    end
  end

  def destroy
    @reviewer.destroy
    redirect_to user_reviewers_path(user_id: @merchant.id), notice:t("reviewers.destroy.success")
  end

  private
  def find_merchant
    @merchant = User.find_by_id(params[:user_id])
    unless @merchant && @merchant.merchant? && current_user.can_access?(@merchant)
      redirect_to refinery.root_path, error: t('reviewers.access.denied')
    end
  end

  def find_reviewer
    @reviewer = @merchant.reviewers.find_by_id(params[:id])
    unless @reviewer
      redirect_to user_reviewers_path(user_id: @merchant), error: t('reviewers.access.denied')
    end
  end
end