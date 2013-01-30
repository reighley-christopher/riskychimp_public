explanatory_variable :normalized_datetime do #TODO: once we have another reliable column, stop looking at normalized datetime
  type :numeric
  input Transaction
  dependencies :integer_datetime
  description "datetime (as seconds since Jan 1 1970) normalized to mean and stdev"
  calculate do |trans|
    (integer_datetime - current_sample.mean(:integer_datetime)) / current_sample.stdev(:integer_datetime)
  end
end
