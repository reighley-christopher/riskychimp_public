explanatory_variable :normalized_log_amount do
  type :numeric
  input Transaction
  dependencies :log_amount
  description "log of amount normalized to sample mean and stdev"
  calculate do |trans|
    (log_amount - current_sample.mean(:log_amount)) / current_sample.stdev(:log_amount)
  end
end
