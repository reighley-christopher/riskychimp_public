explanatory_variable :normalized_addr_la do
  type :numeric
  input Transaction
  dependencies :addr_la
  description "addr_la shifted and scaled by mean and standard deviation"
  calculate do |trans|
    ((addr_la.nil? ? current_sample.mean(:addr_la) : addr_la) - current_sample.mean(:addr_la)) / current_sample.stdev(:addr_la)
  end
end
