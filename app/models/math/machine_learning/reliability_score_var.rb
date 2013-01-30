explanatory_variable :reliability_score do
  type :numeric
  input Transaction
  description "this is a silly score based on a series of arbitrary weights found in FraudModel"
  asset(:c) { [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0 ] }
  dependencies :score_bracket
  calculate do |trans|
    num = score_bracket
    denom = c.sum { |x| x.abs }
    50 + ( 50 * num / denom)
  end
end
