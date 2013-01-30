explanatory_variable :bucketted_amount do
  type :categorical
  input Transaction
  description "the amount sorted into 10 buckets of equal capacity, but in buckets"
  #asset :bucketter do
  #  sample[:amount].bucketter(10)
  #end
  dependencies :log_amount #TODO do we really want log amount?
  calculate do |trans|
    bucketter = current_sample.bucketter(:log_amount, 8)
    bucketter.bucket(log_amount)
  end
end

