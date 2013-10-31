require "csv"
require "delegate"

require "data_chimp/data_column"
require "data_chimp/explanatory_variable"
require "data_chimp/explanatory_variable_dsl"
require "data_chimp/promissory_object"
require "data_chimp/training_sample"

module DataChimp
  #was mattr_accessor but I actually don't want a Rails dependency since data_chimp is actually pretty useful in a much smaller server
  @@path = ""
  def self.path
    return @@path
  end

  def self.path=(val)
    @@path = val
  end
end
