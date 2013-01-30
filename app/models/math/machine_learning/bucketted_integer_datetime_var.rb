explanatory_variable :bucketted_integer_datetime do
  type :categorical
  input Transaction
  description "integer datetime sorted into 10 buckets of equal capacity, but in buckets"
  #asset :bucketter do
  #  sample[:amount].bucketter(10)
  #end
  dependencies :integer_datetime
  calculate do |trans|
    bucketter = current_sample.bucketter(:integer_datetime, 8)
    bucketter.bucket(integer_datetime)
  end
end
