class DataColumn
  def initialize(array)
    @array = array
  end

  def ==(column)
    @array == column.to_a
  end

  def sum()
    @array.reduce(0) do |memo, obj|
      if( obj.is_a? Numeric )
        memo + obj
      else
        memo
      end
    end
  end

  def count()
    @array.reduce(0) do |memo, obj|
      if( obj.is_a? Numeric )
        memo + 1
      else
        memo
      end
    end
  end

  def mean()
    sum.to_f / count
  end

  def median()
    @median ||= (
      sorted = @array.select{ |val| !val.blank? }.sort
      length = sorted.length
      if length == 0
        0
      else
        if length.odd?
          @median = sorted[length / 2]
        else
          @median = (sorted[length / 2] + sorted[(length / 2) - 1]) / 2.0
        end
      end
    )
  end

  def stdev()
    mn = mean
    ( @array.reduce(0) do |memo, obj|
      if( obj.is_a? Numeric )
        memo + (obj - mn) ** 2
      else
        memo
      end
    end.to_f / (count - 1) ) ** 0.5
  end

  def <<(obj)
    @median = nil
    @array << obj
  end

  def to_a()
    @array
  end

  def bucketter(num_buckets)
    sorted = @array.select{ |val| !val.blank? }.sort
    length = sorted.length
    cutoffs = []
    (1...num_buckets).each do |index|
      cutoffs[index - 1] = (sorted[index * (length - 1) / num_buckets] +
          sorted[1 + (index * (length - 1) / num_buckets)]) /
          2.0
    end
    Bucketter.new(cutoffs)
  end

  def sample_distribution(order = lambda{ |x,y| x <=> y })
    order = order.with_column(self) if order.respond_to?(:with_column)
    Distribution.new(self.to_a, order)
  end

  def cast!(type_symbol) #TODO pull this table into a class called ExplanatoryVariableType
    @array = @array.map do |val|
      next nil if val.blank?
      case type_symbol
        when :boolean
          next val if [TrueClass, FalseClass].include?(val.class)
          val == "true"
        when :categorical
          val.to_sym
        when :numeric
          val.to_f
      end
    end
  end
end

class Bucketter
  def initialize(cutoffs)
    @cutoffs = cutoffs
  end

  def bucket(value)
    return "nil" if value.blank?
    lowerbound = "-Infinity"
    cutoffs.each do |test|
      if(test >= value)
        return "(" + lowerbound + ", " + test.to_s + "]"
      end
      lowerbound = test.to_s
    end
    return "(" + lowerbound + ", Infinity)"
  end

  def cutoffs
    @cutoffs
  end
end

class Distribution
  def initialize(data_col, order)
    @array = data_col
    @order = order
  end

  def proportion_under(val)
    @array.compact.select do |sample_val|
      @order.call(sample_val, val) < 0
    end.count.to_f / @array.count
  end
end
