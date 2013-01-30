require('net/http')

module Util
  class Address
    attr_accessor :line1, :line2, :city, :state, :zip, :country

    def initialize(parsed)
      all_blank = true
      [:line1, :line2, :city, :state, :zip, :country].each do |x|
        self.send((x.to_s+"=").to_sym, parsed[x])
        all_blank = false if !parsed[x].blank?
      end
      @country = "US" if @country.blank? && !all_blank
    end

    def self.same?(one, another)
      one_nil = true
      another_nil = true
      some_difference = false
      [:line1, :line2, :city, :state, :zip, :country].each do |symbol|
        one_nil &&= one.send(symbol).nil?
        another_nil &&= another.send(symbol).nil?
        some_difference ||= self.normalize(one.send(symbol)) != self.normalize(another.send(symbol))
      end
      return nil if one_nil || another_nil
      return false if some_difference
      true
    end

    def self.normalize(val)
      return nil if val.nil?
      val.gsub(/\W+/,' ').downcase.strip
    end

    def self.coarse_distance(one, another)
      return nil if one.nil? || another.nil? ||
          (one.country.nil? && one.state.nil? && one.city.nil?) ||
          (another.country.nil? && another.state.nil? && another.city.nil?)
      ret = 3
      [:country, :state, :city].each do |symbol|
        return ret if self.normalize(one.send(symbol)) != self.normalize(another.send(symbol))
        ret = ret - 1
      end
      ret
    end

    def international?()
      @country != "US"
    end

    def coordinates
      zips = ZipDatabase.instance
      zip = zips.find(self.zip, @country )
      return nil if zip.nil?
      return Coordinates.new(zip[:lat], zip[:long])
    end
  end

  class Coordinates
    def initialize(lat, long)
      @lat, @long = lat, long
    end

    def latitude
      @lat
    end

    def longitude
      @long
    end

    def self.coord_distance(one, another)
      return nil if one.nil? || another.nil? || one.latitude.nil? || one.longitude.nil? ||
          another.latitude.nil? || another.longitude.nil?
      lat1 = one.latitude*Math::PI/180
      long1 = one.longitude*Math::PI/180
      lat2 = another.latitude*Math::PI/180
      long2 = another.longitude*Math::PI/180
      lat_diff = (lat2 - lat1).abs
      temp = (long2 - long1).abs
      long_diff =  (temp.abs <= Math::PI) ? temp.abs : (2 * Math::PI - temp.abs)
      a = (Math.sin(lat_diff / 2))**2 + Math.cos(lat1) * Math.cos(lat2) * (Math.sin(long_diff / 2))**2
      c = 2 * Math.atan2(a**0.5, (1 - a)**0.5)
      d = 6371 * c
    end
  end

  def self.distance(place1, place2)
    if !place1.respond_to?(:coordinates)
      raise(TypeError, "expected first parameter to have coordinates method but it is of type #{place1.class}")
    end
    if !place2.respond_to?(:coordinates)
      raise(TypeError, "expected second parameter to have coordinates method but it is of type #{place2.class}")
    end
    Coordinates.coord_distance(place1.coordinates, place2.coordinates)
  end

  class Email
    @@disposable_email = File.read('./lib/data/disposable_email.txt').split("\n")
    def initialize(email)
      @full = email
      return if @full.nil?
      @name, @domain = @full.split("@")
      match = /\.([^.]*)$/.match(@domain)
      @top_level = match[1] if match
    end

    def domain_type
      return nil if @domain.nil?
      if ["gov", "mil", "edu"].include? @top_level
        :protected
      elsif ["me.com", "mac.com", "rocketmail.com", "ymail.com", "yahoo.co.uk", "yahoo.ca", "yahoo.com", "gmail.com", "live.com.au",
             "live.com", "hotmail.co.uk", "hotmail.fr", "hotmail.com", "msn.com"].include? @domain
        :free
      elsif ["aol.co.uk", "aol.com", "earthlink.net", "comcast.net", "sbcglobal.net", "verizon.net", "juno.com",
             "netzero.net", "att.net", "bellsouth.net", "shaw.ca" ].include? @domain
        :service
      elsif @@disposable_email.include? @domain
        :disposable
      else
        :unknown
      end
    end

    def matches_name?(name)
      return nil if @full.nil? || name.nil?
      names = (name.scan(/[\w\.]+/)).select {|x| x.length > 1 && !x.include?(".") }
      names.each do |one_name|
        return true if @full.downcase.include?(one_name.downcase)
        return true if @full.downcase[0..3] == one_name.downcase[0..3]
        return true if @name.downcase.include?(one_name.downcase[0..3]) && one_name.length >= 4
      end
      false
    end

    def number_of_digits
      @name.chars.select{|c| c =~ /[0-9]/}.count
    end

    def matches_name_perfectly?(name)
      return nil if @name.nil? || name.nil?
      param_names = name.downcase.scan(/\w+/)
      email_name = @name.downcase.scan(/\w+/).join("")
      (0...param_names.length).each do |start|
          return true if (param_names[(start...param_names.length)] + param_names[(0...start)]).join('') == email_name
      end
      false
    end

    def self.disposable_email
      @@disposable_email
    end
  end

  class IP
    def initialize(address)
      @address = address
    end

    def self.valid_ip?(ip)
       ip.kind_of?(String) && (/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/ =~ ip)
    end

    def self.load_from_s3
      https = Net::HTTP.new("riskybiz.s3.amazonaws.com", 443)
      https.use_ssl = true
      response = https.get("/geodata/GeoLiteCity.dat")
      File.open('lib/data/GeoLiteCity.dat', 'wb') do |file|
        file.write(response.body)
      end
    end

    def self.db_instance
      if @db_instance.nil?
        self.load_from_s3 unless File.exists?('lib/data/GeoLiteCity.dat')
        @db_instance = GeoIP.new('lib/data/GeoLiteCity.dat')
      end
      @db_instance
    end

    def coordinates
      me = IP.get_location(@address)
      return nil if me.nil?
      Coordinates.new(me[:lat], me[:long])
    end

    def self.get_location(ip)
      return nil unless valid_ip?(ip)
      geo = self.db_instance.city(ip)
      return nil if geo.nil?
      { city: geo["city_name"], state: geo["region_name"],
        country: geo["country_code2"], timezone: geo["timezone"],
        lat: geo["latitude"], long: geo["longitude"] }
    end

    def self.seed_public_computers(array)
      @public = array.select{|val| !val.nil?}
    end

    def self.is_public?(ip)
      return nil if ip.nil?
      return @public.include?(ip)
    end

    def self.address_class(ip)
      return nil if !ip.kind_of?(String) || (/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/ =~ ip).nil?
      first_byte = /^[0-9]*/.match(ip)[0].to_i
      if first_byte <= 126
        return :A
      elsif first_byte <= 191
        return :B
      elsif first_byte <= 223
        return :C
      elsif first_byte <= 239
        return :D
      else
        return :E
      end
    end
  end

  def self.time_there(timezone_there, time_here)
    return nil if time_here.nil?
    begin
      tz_there = ActiveSupport::TimeZone[timezone_there]
      output = tz_there.utc_to_local(time_here.utc)
    rescue
      output = time_here
    end
    { hour: output.hour, minutes: output.min }
  end

  def self.parse_time_param(transaction_date_param, default_time_zone)
    opts = {}.with_indifferent_access
    if transaction_date_param
      transaction_date_param.split(" ").each do |time_part|
        if time_part.start_with?("+") || time_part.start_with?("-")
          opts[:offset] = time_part
        elsif time_part.split("-").size > 1
          opts[:date] = time_part
        elsif time_part.split(":").size > 1
          opts[:time] = time_part
        end
      end
      unless opts[:offset]
        tz = ActiveSupport::TimeZone[default_time_zone]
        tz = ActiveSupport::TimeZone['Zulu'] unless tz
        number_offset = tz.period_for_local(opts[:time]).utc_total_offset()
        formatted_offset = seconds_to_formatted_offset(number_offset)
        opts[:offset] = formatted_offset
      end
      opts[:datetime] = normalize_datetime(transaction_date_param, default_time_zone).strftime("%Y-%m-%d %H:%M:%S %Z") if opts[:time]
      opts[:time] = "#{opts[:date]} #{opts[:time]} #{opts[:offset]}" if opts[:time]
    end
    opts
  end

  def self.normalize_datetime(transaction_date_param, default_time_zone)
    if(transaction_date_param =~ /[+-][0-9][0-9]:[0-9][0-9]/)
      return DateTime.parse(transaction_date_param).utc
    end
    timezone = ActiveSupport::TimeZone[default_time_zone]
    timezone = ActiveSupport::TimeZone['Zulu'] unless timezone
    timezone.local_to_utc(DateTime.parse(transaction_date_param))
  end

  def self.seconds_to_formatted_offset(sec)
    sign = (sec >= 0)? "+" : "-"
    sec = sec.abs
    hours = sec / (3600)
    formatted_hour = (hours >= 10)? "#{hours}" : "0#{hours}"
    mins = (sec % 3600) / 60
    formatted_min = (mins >= 10)? "#{mins}" : "0#{mins}"
    "#{sign}#{formatted_hour}:#{formatted_min}"
  end

  def self.numericize(param)
    return 0 if param.nil?
    yield(param) ? 1 : -1
  end

  module Order
    class OrderBase
      def initialize(&block)
        @block = block
      end

      def with_column(column)
        Proc.new(&@block).curry.call(column)
      end
    end

    def self.number_decreasing
      OrderBase.new { |column, x, y| (y.nil? ? column.median : y) <=> (x.nil? ? column.median : x) }
    end

    def self.number_increasing
      OrderBase.new { |column, x, y| (x.nil? ? column.median : x) <=> (y.nil? ? column.median : y) }
    end

    def self.tf_order
      array_to_order([true, nil, false])
    end

    def self.ft_order
      array_to_order([false, nil, true])
    end

    def self.array_to_order(array)
      lambda { |x, y| array.index(x) <=> array.index(y) }
    end

    def self.string_to_known_order(str)
      begin
        strs = str.sub(/Util::Order::/, "").split(/\(|\)/)
        sym = strs.first.to_sym
        if sym == :array_to_order
          arr = JSON.parse(strs[1])
          arr_without_strings = arr.map do |val|
            val.kind_of?(String) ? val.to_sym : val
          end
          return self.send(sym, arr_without_strings)
        else
          return self.send(sym)
        end
      rescue Exception => e
        e2 = Exception.new("#{self} could not convert '#{str}' to an order." + e.message)
        e2.set_backtrace(e.backtrace)
        raise e2
      end
    end
  end
end
