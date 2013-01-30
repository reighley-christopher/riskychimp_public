class UserSetting < ActiveRecord::Base
  attr_accessible :user, :amount_threshold, :time_zone, :model_params, :model_type
  belongs_to :user

  validates :amount_threshold, numericality: { greater_than_or_equal_to: 0 }
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.zones_map.keys }

  @@stored_models = {}

  def fraud_model
    merchant_id = user.id
    unless @@stored_models.has_key?(merchant_id)
      @@stored_models[merchant_id] = FraudModel.new(merchant_id: merchant_id, class: model_type, model_params_string: model_params)
    end
    return @@stored_models[merchant_id]
  end

  def adjustable_model_parameters
    begin
      klass = model_type.constantize
    rescue
      klass = FraudModel.default_class
    end
    klass.adjustable_model_parameters(self.model_params)
  end

  def set_model_parameters(params)
    raise "only the merchant can set the model parameters" unless user.merchant?
    begin
      array = self.model_type.split("::")
      klass = array.reduce(Kernel) {|memo, name| memo.const_get(name)}
    rescue
      klass = FraudModel.default_class
    end
    str = klass.apply_params(model_params, params)
    self.model_params = str
    @@stored_models.delete( user.id )
    str
  end
end
