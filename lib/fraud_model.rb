class FraudModel
  def initialize(options)
    options.keys.each do |key|
      unless [:merchant_id, :class, :model_params_string].include?(key)
      raise "FraudModel initialize expects a hash containing only the keys " +
                ":merchant_id, :class, and :model_params_string, " +
                "but you passed it '#{key}'. " +
                "If you want to change the behavior, please update this error message " +
                "and add a spec to document the new key."
      end
    end

    merchant = User.find(options[:merchant_id])

    if options[:class].nil?
      @class = FraudModel.default_class
    else
      @class = options[:class].kind_of?(String) ? options[:class].constantize : options[:class]
    end

    model_params = @class.parse_model_params(options[:model_params_string])
    @col_names = @class.column_names(model_params)
    @sample = TrainingSample.new(merchant.transactions.for_learn, @col_names)

    @scorer = @class.new(@sample, model_params)
  end

  def reliability_score(tr)
    model = @scorer

    hash_of_values = {}
    @col_names.each do |col|
      ev = ExplanatoryVariable.lookup(col)
      hash_of_values[col] = ev.evaluate(tr)
    end

    model.apply(hash_of_values)
  end

  def explain_factor(score, factor)
    proportion = (score.proportion_of_score[factor] * 100).floor
    quantile = (score.quantile_of_feature[factor] * 100).floor
    value = score.value_of_feature[factor]
    ev = ExplanatoryVariable.lookup(factor)
    description = ev.description

    "The #{factor} factor accounted for #{proportion}% of the score.\n" +
        "The value of #{factor} was #{value}.\n" +
        "This transaction's #{factor} was worse than #{quantile}% of transactions in the sample.\n" +
        "The #{factor} factor represents #{description}.\n"
  end

  def factor_details(score, factor)
    ev = ExplanatoryVariable.lookup(factor)
    {
      :value => score.value_of_feature[factor],
      :proportion => (score.proportion_of_score[factor] * 100).floor,
      :quantile => (score.quantile_of_feature[factor] * 100).floor,
      :description => ev.description.titleize
    }
  end

  def explain(score)
    variables = score.proportion_of_score.sort_by{|key, value| -value}.slice(0, 3).map{|array| array[0]}
    variables.map{ |var| explain_factor(score, var) }.join('\n')
  end

  def extracted_factors(score)
    score.proportion_of_score.reject{ |key, value| value == 0 || value.to_f.nan? }
      .sort_by{ |key, value| -value }.slice(0, 5).map{ |array| array[0] }
  end

  def score_details(score)
    variables = extracted_factors(score)
    present_value_factors = score.value_of_feature.reject{|key, value| value.blank?}.keys
    variables &= present_value_factors

    variables.map do |key|
      factor_details(score, key)
    end
  end

  def self.default_class
    Scorer::OutlierOrder
  end
end
