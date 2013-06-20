class ExplanatoryVariableDSL
  attr_accessor :variable, :current_sample

  def initialize(main_block, variable)
    @variable = variable
    @dependencies = []
    instance_eval(&main_block)
  end

  def type(type)
    @variable.type = type
  end

  def input(input)
    @variable.input = input
  end

  def description(desc)
    @variable.description = desc
  end

  def asset(sym, &block)
    val = nil
    define_singleton_method(sym) do
      if(!@current_context.nil? && @current_context.has_key?(sym))
        next @current_context[sym]
      end
      val.nil? ? val = block.call() : val
    end
  end

  def dependencies(*symbols)
    @dependencies += symbols
  end

  def sample
    raise NoSampleError if @current_sample.nil?
    return @current_sample
  end

  def calculate(&block)
    procedure = lambda do |input, token, sample, precomputed_values, context|
      @current_context = context
      self.current_sample = sample
      @dependencies.each do |sym|
        if precomputed_values.keys.include?(sym)
          define_singleton_method(sym) { precomputed_values[sym] }
        else
          ev = ExplanatoryVariable.lookup(sym)
          define_singleton_method(ev.name) { ev.tracking_evaluate(input, token, sample, precomputed_values, context) } if ev
        end
      end
      next precomputed_values[@variable.name] if precomputed_values[@variable.name]
      block.call(input)
    end
    @variable.calculate = procedure
  end
end
