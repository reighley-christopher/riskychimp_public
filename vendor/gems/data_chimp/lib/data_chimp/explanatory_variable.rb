def explanatory_variable(name, &block)
  variable = ExplanatoryVariable.new(name)
  ExplanatoryVariableDSL.new(block, variable)
  ExplanatoryVariable.register(variable)
rescue => e
  ExplanatoryVariable.loading_exceptions << e
end

class ExplanatoryVariable
  attr_accessor :name, :type, :input,
    :description, :calculate, :dependencies
  @catalog = {}

  def initialize(name)
    @name = name
    token = []
  end

  def evaluate(input, extra = {})
    token = []
    precomps = extra[:precomputed_values]
    precomps = {} unless precomps
    context = extra[:context]
    sample = extra[:sample] #|| input.user.transactions.for_learn #TODO Reighley does not think we should have a default sample of any kind.
    #unless sample.kind_of? PromissoryObject
    #  sample = PromissoryObject.new(TrainingSample, [sample])
    #end
    tracking_evaluate(input, token, sample, precomps, context)
  end

  def tracking_evaluate(input, token, sample, precomputed_values, context) #TODO: make private? or only show to DSL?
    raise SelfReferenceError.new("You've entered into an infinite loop of explanatory variable lookups : ", token + [@name]) if token.include?(@name)
    new_token = token.dup
    new_token.push(@name)

    begin
      retval = @calculate.call(input, new_token, sample, precomputed_values, context)
    rescue NoSampleError, SelfReferenceError => er
      raise er
    rescue Exception => er  #because ExplanatoryVariables are intended for batch processing, do not halt the process just because one variable had one bad value.
      retval = nil
      @last_error = er
    end
    return retval

  end

  def last_error
    @last_error
  end

  class << self
    attr_accessor :loading_exceptions
    @loading_exceptions = []

    def catalog
      return @catalog.clone
    end

    def lookup(name)
      load_variable_definitions
      @catalog[name]
    end

    def load_variable_definitions
      return if @variable_definitions_loaded
      self.loading_exceptions = []
      Dir[DataChimp.path].each do |filename|
        load(filename)
      end
      @variable_definitions_loaded = true
      unless loading_exceptions.empty?
        messages = []
        loading_exceptions.each do |e|
          messages << e.message
          Rails.logger.error(e.message)
          Rails.logger.error(e.backtrace.join("\n"))
        end
        raise "Error loading variables definition: #{messages.join("\n")}"
      end
    end

    def register(variable)
      @catalog[variable.name] = variable
    end
  end
end

class SelfReferenceError < StandardError
  def initialize(msg = "You've entered into an infinite loop of explanatory variable lookups", chain = [])
    super(msg + chain.inspect)
  end
end

class NestedLookupError < StandardError
  def initialize(msg = "You used ExplanatoryVariable.lookup inside another variable's calculate block, " +
                 "but you should have used a dependencies declaration")
    super(msg)
  end
end

class NoSampleError < StandardError
  def initialize(msg = "This variable computes a statistic but no sample has been specified")
    super(msg)
  end
end
