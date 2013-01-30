class ApiController < ApplicationController
  def transactions
    if (user = User.find_by_api_key(params[:api_key]))
      sign_in :user, user
    end
    if current_user
      opts = params.dup
      transaction_attributes = process_time_params(opts)
      transaction_attributes[:device_id] = Thumbprint.generate(transaction_attributes)
      @transaction = current_user.transactions.create(transaction_attributes.slice(*Transaction.available_attrs))
      score = @transaction.calculate_score!
      score_details = current_user.fraud_model.score_details(score)

      render json: { id: @transaction.id, score: score, :score_details => score_details }
    else
      render json: { error: t('api.invalid_key') }, status: 403
    end
  rescue Exception => exception
    puts "Error during processing: #{$!}"
    puts "Backtrace:\n\t#{exception.backtrace.join("\n\t")}"
    render json: { error: exception.message }, status: 500
  end

  private
  def process_time_params(options = {})
    options[:unparsed_transaction_datetime] = options[:transaction_datetime]
    ret = Util::parse_time_param(options[:transaction_datetime], current_user.time_zone)
    opts = options.dup
    opts[:transaction_datetime_offset] = ret[:offset]
    opts[:transaction_datetime] = ret[:datetime]
    opts
  end
end

