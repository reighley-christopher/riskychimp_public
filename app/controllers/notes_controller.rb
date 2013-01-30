class NotesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_transaction

  def create
    params[:note] ||= {}
    @note = Note.new(params[:note].merge(transaction: @transaction))
    if @note.save
      @msg = t("transactions.notes.created")
    end
    respond_to do |format|
      format.html {
        redirect_to transaction_path(@transaction)
      }
      format.js
    end
  end

  def update
    @note = @transaction.note
    if @note && @note.update_attributes(params[:note])
      @msg = t("transactions.notes.updated")
    end
    respond_to do |format|
      format.html {
        redirect_to transaction_path(@transaction)
      }
      format.js
    end
  end

  private
  def load_transaction
    unless Transaction.find_by_id(params[:transaction_id])
      flash[:error] = t("transactions.notexisted")
      redirect_to_with_js transactions_path
    else
      @transaction = current_user.related_transactions.find_by_id(params[:transaction_id])
      unless @transaction
        flash[:error] = t("transactions.access.denied")
        redirect_to_with_js transactions_path
      end
    end
  end
end
