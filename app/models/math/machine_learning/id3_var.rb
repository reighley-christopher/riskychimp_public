explanatory_variable :id3 do
  type :boolean
  input Transaction
  description "applies an ID3 decision tree"
  dependencies :bucketted_amount, :bucketted_integer_datetime, :bucketted_addr_la
  calculate do |trans|
    m = Classifier::DecisionTreeID3.new(current_sample, [:bucketted_amount, :bucketted_integer_datetime, :bucketted_addr_lq])
    m.predict([bucketted_amount, bucketted_integer_datetime, bucketted_addr_la])
  end
end
