explanatory_variable :svm do
  type :boolean
  input Transaction
  description "applies a support vector machine"
  dependencies :normalized_log_amount, :normalized_datetime, :normalized_addr_la
  calculate do |trans|
    m = Classifier::SVMachine.new(current_sample, [:normalized_log_amount, :normalized_datetime, :normalized_addr_la])
    m.predict([normalized_log_amount, normalized_datetime, normalized_addr_la])
  end
end

