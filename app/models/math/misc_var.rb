
explanatory_variable :local_time do
  type :numeric
  input Transaction
  description "local time in fractional number of hours since midnight, based on the time zone of the IP address"
  calculate do |trans|
    ip_hash = Util::IP.get_location(trans.ip)
    next nil if ip_hash.nil?
    localtime = Util::time_there(ip_hash[:timezone], trans.transaction_datetime)
    localtime[:hour] + localtime[:minutes] / 60.0
  end
end

explanatory_variable :amount do
  type :numeric
  input Transaction
  description "the amount of the transaction"
  calculate do |trans|
    trans.amount
  end
end

explanatory_variable :nonnull_count do
  type :numeric
  input Transaction
  description "counts the number of keys that were provided with values"
  calculate do |trans|
    if trans.other_data
      other_data = trans.other_data
    else
      other_data = {}
    end
    trans.attributes.select do |attr|
      local = trans.send(attr)
      !local.blank?
    end.size +
    other_data.keys.select do |key|
      !other_data[key].blank?
    end.size
  end
end

explanatory_variable :null_count do
  type :numeric
  input Transaction
  description "counts the number of keys that were provided without values"
  calculate do |trans|
    if trans.other_data
      other_data = trans.other_data
    else
      other_data = {}
    end
    trans.attributes.select do |attr|
      local = trans.send(attr)
      local.blank?
    end.size +
    other_data.keys.select do |key|
      other_data[key].blank?
    end.size
  end
end

explanatory_variable :nonnull_hash do
  type :categorical
  input Transaction
  description "hashes the alphabetical list of nonnull/nonnil attributes"
  calculate do |trans|
    Digest::SHA1.hexdigest(
        ((trans.attributes.select {|key, value| !value.nil? }.keys -
        ["id","client_id","created_at","updated_at","status", "other_data"] ) +
        trans.other_data.select {|key, value| !value.nil? }.keys ).sort.join('')
    )
  end
end