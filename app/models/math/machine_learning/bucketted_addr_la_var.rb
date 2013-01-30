explanatory_variable :bucketted_addr_la do
  type :categorical
  input Transaction
  description "integer datetime sorted into 10 buckets of equal capacity, but in buckets"
  #asset :bucketter do
  #  sample[:amount].bucketter(10)
  #end
  dependencies :addr_la
  calculate do |trans|
    bucketter = current_sample.bucketter(:addr_la, 8)
    bucketter.bucket(addr_la)
  end
end
