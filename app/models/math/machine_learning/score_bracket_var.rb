explanatory_variable :score_bracket do
  type :numeric
  input Transaction
  description "this is the numerator for a silly score based on a series of arbitrary weights found in FraudModel"
  asset(:c) { [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0 ] }
  dependencies :amount, :addr_ia, :cards_by_ip, :cards_by_print,
               :frequency_of_ip_today, :frequency_of_print_today, :addr_la_same,
               :international, :customer_loyalty, :domain_type, :email_match,
               :nonnull_count, :null_count
  calculate do |trans|
    Util::numericize(amount) { |x| x > 44 } * c[0] +
        Util::numericize(addr_ia) { |x| x > 20 } * c[1] +
        Util::numericize(cards_by_ip) { |x| x > 1 }  * c[2] +
        Util::numericize(cards_by_print) { |x| x > 1 } * c[3] +
        Util::numericize(frequency_of_ip_today) { |x| x > 1 }  * c[4] +
        Util::numericize(frequency_of_print_today) { |x| x > 1 } * c[5] +
        Util::numericize(addr_la_same) { |x| x == true } * c[6] +
        Util::numericize(international) { |x| x == true } * c[7] +
        Util::numericize(customer_loyalty) { |x| x > 1 } * c[8] +
        Util::numericize(domain_type) { |x| x == :protected } * c[9] +
        Util::numericize(email_match) { |x| x == true } * c[10] +
        ((nonnull_count - null_count) / (null_count + nonnull_count)) * c[11]
  end
end
