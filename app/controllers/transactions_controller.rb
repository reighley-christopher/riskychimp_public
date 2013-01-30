class TransactionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user, :only => [:index, :update_amount_threshold]
  before_filter :find_transaction, :only => [:show, :change_status, :email_detail]
  helper_method :sort_column, :sort_direction

  def index
    load_transactions
  end

  def show
    @note = @transaction.note || Note.new(transaction: @transaction)
  end

  def change_status
    if @transaction.status_events.include?(params[:status].to_sym) && current_user.can_change_status?(params[:status])
      @transaction.send(params[:status].to_sym)
    end
    respond_to do |format|
      format.js
    end
  end

  def update_amount_threshold
    if @user.user_setting.update_attributes(params[:user_setting])
      redirect_to transactions_path(user_id: @user), notice: t('users.setting.updated')
    else
      load_transactions
      render :action => 'index'
    end
  end

  def email_detail
    @transactions = Transaction.with_email(@transaction.email)
    respond_to do |format|
      format.js
    end
  end

  private

  def sort_column
    Transaction.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def load_transactions
    date_from = case params[:from]
                  when 'today' then Time.now.beginning_of_day
                  when '7_days' then 7.days.ago.beginning_of_day
                  else nil
                end
    @transactions = @user.related_transactions.amount_from(@user.amount_threshold).date_from(date_from).order("#{sort_column} #{sort_direction}").paginate(:page => current_page)
  end

  def find_transaction
    @transaction = current_user.related_transactions.find_by_id(params[:id])
    unless @transaction
      flash[:error] = t("transactions.access.denied")
      redirect_to_with_js transactions_path
    end
  end

  def find_user
    if current_user.admin?
      @user = User.find_by_id(params[:user_id]) || current_user
    else
      @user = current_user
    end
  end
end
