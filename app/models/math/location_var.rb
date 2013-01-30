require 'explanatory_variable'

explanatory_variable :addr_la do
  type :numeric
  input Transaction
  description "distance between zip codes for 'location' address and 'account' address"
  calculate do |trans|
    location_addr = Util::Address.new(city: trans.shipping_city, country: trans.shipping_country,
                                       state: trans.shipping_state, zip: trans.shipping_zip)
    other_data = trans.other_data
    account_addr = Util::Address.new(city: other_data[:account_city], country: other_data[:account_country],
                                      state: trans.shipping_state, zip: other_data[:account_zip])
    Util::distance(location_addr, account_addr)
  end
end

explanatory_variable :addr_li do
  type :numeric
  input Transaction
  description "distance between 'location' address zip and IP address"
  calculate do |trans|
    location_addr = Util::Address.new(city: trans.shipping_city, country: trans.shipping_country,
                                      state: trans.shipping_state, zip: trans.shipping_zip)
    ip = Util::IP.new(trans.ip)
    Util::distance(location_addr, ip)
  end
end

explanatory_variable :addr_ia do
  type :numeric
  input Transaction
  description "distance between IP address and 'account' address"
  calculate do |trans|
    ip = Util::IP.new(trans.ip)
    other_data = trans.other_data
    account_addr = Util::Address.new(city: other_data[:account_city], country: other_data[:account_country],
                                     state: trans.shipping_state, zip: other_data[:account_zip])
    Util::distance(ip, account_addr)
  end
end

explanatory_variable :international do
  type :boolean
  input Transaction
  description "is this an international shipping address"
  calculate do |trans|
    location_addr = Util::Address.new(city: trans.shipping_city, country: trans.shipping_country,
                                      state: trans.shipping_state, zip: trans.shipping_zip)
    location_addr.international?
  end
end

explanatory_variable :addr_la_same do
  type :boolean
  input Transaction
  description "whether location and account address are exactly the same"
  calculate do |trans|
    location_addr = Util::Address.new(city: trans.shipping_city, country: trans.shipping_country,
                                      state: trans.shipping_state, zip: trans.shipping_zip)
    other_data = trans.other_data
    account_addr = Util::Address.new(city: other_data[:account_city], country: other_data[:account_country],
                                     state: trans.shipping_state, zip: other_data[:account_zip])
    Util::Address.same?(location_addr,account_addr)
  end
end