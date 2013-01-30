explanatory_variable :log_amount do
  type :numeric
  input Transaction
  dependencies :amount
  description "natural logarithm of the amount"
  calculate do |trans|
    Math.log(amount)
  end
end
