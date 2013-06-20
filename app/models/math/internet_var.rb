
explanatory_variable :email_match do
  type :boolean
  input Transaction
  description "does email address match name? true or false"
  calculate do |trans|
    next nil if trans.email.nil?
    email = Util::Email.new(trans.email)
    name = trans.name
    email.matches_name?(name)
  end
end

explanatory_variable :domain_type do
  type :categorical
  input Transaction
  description "type of email address: protected, free, or unknown"
  calculate do |trans|
    email = Util::Email.new(trans.email)
    email.domain_type
  end
end

explanatory_variable :ip_exists do
  type :boolean
  input Transaction
  description "is the IP address in the IP database? true or false"
  calculate do |trans|
    next nil if trans.ip.nil?
    location = Util::IP.get_location(trans.ip)
    !location.nil?
  end
end

explanatory_variable :public_ip do
  type :boolean
  input Transaction
  asset(:pubs) { Util::IP.seed_public_computers(Transaction.find_public_ips) }
  description "is this ip used by people with distinct email addresses"
  calculate do |trans|
    Util::IP.is_public?(trans.ip)
  end
end

explanatory_variable :network do
  type :categorical
  input Transaction
  description "lookup the network provider via whois"
  calculate do |trans|
    WhoisNetid.network(trans.ip)
  end
end

explanatory_variable :address_class do
  type :categorical
  input Transaction
  description "determine whether the Transaction's IP address class is A, B, C, D, or E"
  calculate do |trans|
    Util::IP.address_class(trans.ip)
  end
end

explanatory_variable :network_owner_type do
  type :categorical
  input Transaction
  description "try to guess from whois data on the ip address what sort of a network this is"
  calculate do |trans|
    WhoisNetid.network_owner_type(trans.ip)
  end
end

explanatory_variable :currency_match do
  type :boolean
  input Transaction
  description "is this currency matched with country"
  calculate do |trans|
    other_data = trans.other_data
    country_code = other_data["account_country"] || trans.shipping_country
    currency = other_data["denomination"]

    if country_code.present? && currency.present?
      country = Country[country_code]
      next true if country && country.currency["code"] == currency
      false
    else
      nil
    end
  end
end
