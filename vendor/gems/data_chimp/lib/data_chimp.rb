require "csv"
require "delegate"

require "data_chimp/data_column"
require "data_chimp/explanatory_variable"
require "data_chimp/explanatory_variable_dsl"
require "data_chimp/promissory_object"
require "data_chimp/training_sample"

module DataChimp
  mattr_accessor(:path)
end