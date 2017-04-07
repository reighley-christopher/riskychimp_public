  class TrainingSample
    def initialize(data_source, column_list = nil)
      if data_source.class == String
        initialize_from_filename(data_source)
      else
        initialize_from_array(data_source, column_list)
      end
    end

    def initialize_from_array(array, column_list)
      evs = column_list.map do |name|
        raise "Expected the column name '#{name}' to be a Symbol, but it was a #{name.class}" unless name.class == Symbol
        ExplanatoryVariable.lookup(name)
      end
      @col_names = column_list
      @size = array.length
      @cols = {}
      evs.each{|ev| @cols[ev.name] = DataColumn.new(array.map{ |tr| ev.evaluate(tr) }) }
    end

    def initialize_from_filename(filename)
      begin
        raw_array = CSV.read(filename)
      rescue SystemCallError
        raise IOError.new("File not found : #{filename}")
      end
      @size = raw_array.length - 1
      @col_names = raw_array[0].map { |str| str.strip.to_sym }
      @cols = {}
      @col_names.each { |sym| @cols[sym] = DataColumn.new([]) }

      raw_array.slice(1, raw_array.length).each do |row|
        (0...row.length).each do |i|
          @cols[@col_names[i]] << (row[i].blank? ? nil : row[i].strip)
        end
      end
      @cols.each do |key, value|
        ev = ExplanatoryVariable.lookup(key)
        value.cast!(ev.type) if ev
      end
    end

    def size
      @size
    end

    def mean(col)
      @cols[col].mean
    end

    def stdev(col)
      @cols[col].stdev
    end

    def bucketter(col, num)
      @cols[col].bucketter(num)
    end

    def sample_distribution(col, order=lambda{ |x,y| x <=> y })
      @cols[col].sample_distribution(order)
    end

    def [](name)
      @cols[name].to_a
    end

    def col_names
      @col_names
    end

    def hashify(row)
      hash = {}
      (0...(row.length)).map do |i|
        hash[col_names[i]] = row[i]
      end
      hash
    end

    def find_row(index)
      col_names.map { |col| @cols[col].to_a[index] }
    end

    def write_to_csv(filename)
      csv = CSV.open(filename, "w")
      csv << @col_names
      (0...size).each{ |index| csv << @col_names.map{ |col| @cols[col].to_a[index] } }
      csv.close()
    end
  end
