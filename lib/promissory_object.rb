 class PromissoryObject < SimpleDelegator
  def initialize(klass, parameters)
    super(nil)
    @parameters = parameters
    @klass = klass
  end
  def method_missing(sym, *args, &block)
    __setobj__(@klass.new(*@parameters)) if __getobj__.nil?
    super(sym, *args, &block)
  end
end
