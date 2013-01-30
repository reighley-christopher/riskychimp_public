module Scorer
  class Score < SimpleDelegator
    attr_reader :quantile_of_feature, :proportion_of_score, :value_of_feature

    def initialize(value, proportions, quantiles, values)
      super(value)
      @proportion_of_score = proportions
      @quantile_of_feature = quantiles
      @value_of_feature = values
    end
  end

  class OutlierOrder
    attr_accessor :sample

    def self.term(name, hash)
      @@terms[self] = {} if @@terms[self].nil?
      @@terms[self][name] = hash
    end

    def terms
      @@terms[self.class]
    end

    @@terms = {}

    def initialize(sample, model_parameters)
      @sample = sample
      @terms = model_parameters[:terms]

      @distributions = {}
      @weights = {}
      @terms.each{ |key, val| @weights[key.to_sym] = val[:weight] }
      @terms.each do |key, val|
        ord = val[:order].kind_of?(String) ? Util::Order.string_to_known_order(val[:order]) : val[:order]
        sym = key.to_sym #TODO: can I get rid of all these to_sym's here?
        @distributions[sym] = sample.sample_distribution(sym, ord) if @sample.col_names.include?(sym)
      end
      @total_weight = @weights.values.sum.to_f
    end

    def quantile_list(hash_of_values)
      @distributions.reduce({}) do |hmemo, (name, distribution)|
        hmemo[name] = distribution.proportion_under(hash_of_values[name])
        hmemo
      end
    end

    def apply(hash={})
      quantiles = quantile_list(hash)
      factors = quantiles.reduce({}) do |hmemo, (name, value)|
        hmemo[name] = (1 - value) ** (@weights[name] / @total_weight)
        hmemo
      end
      score = 1 - factors.values.reduce(1) { |memo, factor| memo * factor}
      proportions = factors.reduce({}) do |hmemo, (key, value)|
        if value == 0
          val = 1.0
        elsif value == 1
          val = 0.0
        else
          val = (Math.log(value) / Math.log(1.0 - score))
        end
        hmemo[key] = val
        hmemo
      end
      Score.new(score, proportions, quantiles, hash)
    end

    def self.parse_model_params(params_string)
      return default_model_params if params_string.nil?
      hsh = JSON.parse(params_string).with_indifferent_access
    end

    def self.default_model_params
      {
          terms: {
              amount: { order: "Util::Order::number_increasing", weight: 1 },
              addr_ia: { order: "Util::Order::number_increasing", weight: 1 },
              cards_by_ip: { order: "Util::Order::number_increasing", weight: 1 },
              cards_by_print: { order: "Util::Order::number_increasing", weight: 1 },
              frequency_of_ip_today: { order: "Util::Order::number_increasing", weight: 1 },
              frequency_of_print_today: { order: "Util::Order::number_increasing", weight: 1 },
              addr_la_same: { order: "Util::Order::tf_order", weight: 1 },
              international: { order: "Util::Order::ft_order", weight: 1 },
              customer_loyalty: { order: "Util::Order::number_decreasing", weight: 1 },
              domain_type: { order: "Util::Order::array_to_order(#{[:protected, :service, :free, :unknown, nil, :disposable].to_json})",
                             weight: 1 },
              email_match: { order: "Util::Order::tf_order", weight: 1 }
          }
      }
    end

    def self.adjustable_model_parameters(a_string)
      #TODO this is part of the interface of models _in general_ so it should go in a module
      #TODO and be included
      terms = parse_model_params(a_string)[:terms]
      ret = terms.reduce({}) do |hmemo, (name, specs)|
        hmemo[name.to_sym] = terms[name][:weight]
        hmemo
      end
      ret
    end

    def self.apply_params(a_string, a_hash)
      #TODO this is part of the interface of models _in general_ so it should go in a module
      #TODO and be included
      a_string = default_model_params.to_json unless a_string
      params = parse_model_params(a_string)
      a_hash.each {|key, value| params[:terms][key][:weight] = value.to_f if params[:terms][key] }
      params.to_json
    end

    def self.column_names(params = default_model_params)
      params[:terms].keys.map {|key| key.to_sym}
    end
  end
end
