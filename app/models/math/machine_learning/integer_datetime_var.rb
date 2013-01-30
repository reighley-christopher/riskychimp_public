explanatory_variable :integer_datetime do
  type :numeric
  input Transaction
  description "transaction.datetime as number of seconds since 1970"
  calculate do |trans|
    trans.transaction_datetime.to_time.to_i
  end
end
