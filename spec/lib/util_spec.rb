require 'spec_helper'

describe Util do
  before :all do
    Util::ZipDatabase.instance.populate_zip_location
  end

  describe Util::Address do
    describe "#same?" do
      before :all do
        @address1 = Util::Address.new(line1: "123 Fake Street", city: "Nowhere", state: "NV", zip: "88888")
        @address1a = Util::Address.new(line1: "123 Fake  Street", city: "Nowhere", state: "NV", zip: "88888")
        @address2 = Util::Address.new(line1: "234 Imaginary Lane", city: "Somewhere", state: "IL", zip: "99999")
        @address3 = Util::Address.new(line1: "123 Fake Street", city: "Somewhere", state: "IL", zip: "99999")
        @address4 = Util::Address.new(line1: nil, city:"Somewhere", state:"IL", zip:"99999")
        @niladdress = Util::Address.new(line1: nil, city: nil, state: nil, zip: nil)
      end

      context "when the addresses agree" do
        it "should return true" do
          Util::Address.same?(@address1, @address1).should be_true
          Util::Address.same?(@address1, @address1a).should be_true
          Util::Address.same?(@address4, @address4).should be_true
        end
      end

      context "when the addresses do not agree" do
        it "should return false" do
          Util::Address.same?(@address1, @address2).should be_false
          Util::Address.same?(@address1, @address2).should be_false
          Util::Address.same?(@address1, @address3).should be_false
          Util::Address.same?(@address4, @address3).should be_false
        end
      end

      context "when one of the addresses is nil" do
        it "should return nil" do
          Util::Address.same?(@address1, @niladdress).should be_nil
          Util::Address.same?(@niladdress, @niladdress).should be_nil
        end
      end
    end

    describe "#international?" do
      before :all do
        @address3 = Util::Address.new(:country => "US")
        @address4 = Util::Address.new(:country => "Vietnam")
        @address5 = Util::Address.new({:state => "CA" })
      end

      it "should identify US as 'domestic'" do
        @address3.international?.should be_false
        @address4.international?.should be_true
      end

      it "should identify blank country as domestic" do
        @address5.international?.should be_false
      end
    end

    describe "#coarse_distance" do
      before :all do
        @address0 =
            Util::Address.new(line1: "100 Market St.", city: "San Francisco", state: "CA", country: "US", zip: "94103")
        @different_line1 =
            Util::Address.new(line1: "200 Market St.", city: "San Francisco", state: "CA", country: "US")
        @different_city =
            Util::Address.new(line1: "100 Market St.", city: "Sacramento", state: "CA", country: "US")
        @different_state =
            Util::Address.new(line1: "100 Market St.", city: "San Francisco", state: "AZ", country: "US")
        @different_country =
            Util::Address.new(line1: "100 Market St.", city: "Sacramento", state: "CA", country: "AR")
        @niladdress =
            Util::Address.new(line1: nil, city: nil, state: nil, zip: nil)
      end

      it "should return a reasonable distance" do
        Util::Address.coarse_distance(@address0, @niladdress).should be_nil
        Util::Address.coarse_distance(@niladdress, @niladdress).should be_nil
        Util::Address.coarse_distance(@address0, @different_line1).should == 0
        Util::Address.coarse_distance(@address0, @different_city).should == 1
        Util::Address.coarse_distance(@address0, @different_state).should == 2
        Util::Address.coarse_distance(@address0, @different_country).should == 3
      end
    end

    describe "#coordinates" do
      before do
        @address_reasonable =
            Util::Address.new(line1: "100 Market St.", city: "San Francisco", state: "CA", country: "US", zip: "94103")
        @address_unreasonable =
            Util::Address.new(line1: "123 Fake Street", city: "Nowhere", state: "NV", zip: "88888")
      end

      it "should return the coordinates of the address" do
        Util::Coordinates.coord_distance(@address_reasonable.coordinates, Util::Coordinates.new(37.77, -122.41)).
            should be < 1
        (@address_unreasonable).coordinates.should be_nil
      end
    end
  end

  describe Util::Coordinates do
    describe "#coord_distance" do
      it "should return the Haversine distance between the two coordinates, in km" do
        place1 = Util::Coordinates.new(10, 20)
        place2 = Util::Coordinates.new(30, 40)
        place3 = Util::Coordinates.new(0, 10)
        place4 = Util::Coordinates.new(0, 20)
        place5 = Util::Coordinates.new(-85, 0)
        place6 = Util::Coordinates.new(-85, 180)
        place7 = Util::Coordinates.new(11, -170)
        place8 = Util::Coordinates.new(11, -110)
        placenil = Util::Coordinates.new(nil, nil)
        Util::Coordinates.coord_distance(placenil, place1).should be_nil
        Util::Coordinates.coord_distance(nil, place1).should be_nil
        Util::Coordinates.coord_distance(place1, nil).should be_nil
        Util::Coordinates.coord_distance(place1, place2).should be_within(1).of(3041)
        Util::Coordinates.coord_distance(place3, place4).
            should be_within(0.01).of(Util::Coordinates.coord_distance(place5, place6))
        Util::Coordinates.coord_distance(place2, place7).
            should be_within(0.01).of(Util::Coordinates.coord_distance(place2, place8))
        Util::Coordinates.coord_distance(place1, place8).
            should be_within(5).of(14010)
        Util::Coordinates.coord_distance(place8, place1).
            should be_within(0.01).of(Util::Coordinates.coord_distance(place1, place8))
      end
    end
  end

  describe Util::Email do
    before :all do
      @email1 = Util::Email.new("bob.safe@irs.gov")
      @email2 = Util::Email.new("obviousfraud1235@hotmail.com")
      @emaila = Util::Email.new("bob@misc.com")
      @email3 = Util::Email.new("jonathansomebody@example.com")
      @email4 = Util::Email.new("imsomebody@example.com")
      @email5 = Util::Email.new("jonathan1@example.com")
      @email6 = Util::Email.new("joker@jonathan.com")
      @email7 = Util::Email.new("jonsome@example.com")
      @email8 = Util::Email.new("@.")
      @email9 = Util::Email.new("Dr.hello@example.com")
      @email10 = Util::Email.new("z@example.com")
      @email11 = Util::Email.new("jr@example.com")
      @emailnil = Util::Email.new(nil)
      @emaildisposable = Util::Email.new("jon@mailinator.com")
    end

    describe "#domain_type" do
      it "should return protected, free, or unknown appropriately" do
        @email1.domain_type.should == :protected
        @email2.domain_type.should == :free
        @emaila.domain_type.should == :unknown
        @emailnil.domain_type.should be_nil
        @emaildisposable.domain_type.should == :disposable
      end
    end

    describe "#matches_name?" do
      it "should return true of email matches name, false if does not match, nil if email or name is nil" do
        @email1.matches_name?("Bob L. Safe").should be_true
        @email2.matches_name?("Bob L. Safe").should be_false
        @email2.matches_name?("Obvious Fraud").should be_true
        @email3.matches_name?("Jonathan Somebody").should be_true
        @email4.matches_name?("Jonathan Somebody").should be_true
        @email5.matches_name?("Jonathan Somebody").should be_true
        @email6.matches_name?("Jonathan Somebody").should be_true
        #@email7.matches_name?("Jonathan Somebody").should be_false
        @email3.matches_name?("").should be_false
        @email3.matches_name?("Jonathan").should be_true
        @email8.matches_name?("Jon").should be_false
        @email9.matches_name?("Dr. Jonathan Somebody").should be_false
        @email10.matches_name?("Jonathan Z Somebody").should be_false
        @email11.matches_name?("Jonathan Somebody Jr.").should be_false
        @emailnil.matches_name?("Jonathan Somebody Jr.").should be_nil
        @email11.matches_name?(nil).should be_nil
      end

      it "should identify the same proportion of matches as in the sample read by humans" do
        all_data = CSV.open('spec/lib/test_emails.csv').to_a
        training_data = all_data.select {|row| !row[2].blank?}
        testing_data = all_data.select {|row| row[2].blank? }
        training_pr = (training_data.select{ |row| row[2].downcase == 'true'}.size * 1.0)/training_data.size
        testing_pr = (testing_data.select do |row|
          em = Util::Email.new(row[1])
          em.matches_name?(row[0])
        end.size * 1.0)/testing_data.size
        testing_pr.should be_within(0.05).of(training_pr)
        testing_pr.should_not == training_pr #sanity check
      end
    end

    describe "#number_of_digits" do
      it "should return the number of numeric digits before the @ sign" do
        @email1.number_of_digits.should == 0
        @email2.number_of_digits.should == 4
      end
    end

    describe "#matches_name_perfectly?" do
      it "should return true if the email is exactly the persons name, up to punctuation and spaces" do
        @email1.matches_name_perfectly?("Bob Safe").should be_true
        @email1.matches_name_perfectly?("Safe Bob").should be_true
        @email1.matches_name_perfectly?("Safer Bob").should be_false
        @email1.matches_name_perfectly?("Safe. Bob").should be_true
        @email1.matches_name_perfectly?("Bob Andronicus Safe").should be_false
        @email1.matches_name_perfectly?("Bob Safe Sr.").should be_false
        @email3.matches_name_perfectly?("Body, Jonathan Some").should be_true
        @email3.matches_name_perfectly?("Jonathan Bod Somebody").should be_false
      end
    end
  end

  describe Util::IP do
    describe "#get_location" do
      it "should return a hash containing the location of the IP address" do
        ip = "8.8.8.8"
        test = Util::IP.get_location(ip)
        { city: 'Mountain View', state: 'CA', country: 'US', timezone: 'America/Los_Angeles' }.each do |key, value|
          test[key].should == value
        end
        { lat: 37.4192, long: -122.0574 }.each do |key, value|
          test[key].should be_within(0.01).of(value)
        end
      end

      it "should respond stoically to bad input" do
        Util::IP.get_location(0).should be_nil
        Util::IP.get_location("bad string").should be_nil
        Util::IP.get_location(nil).should be_nil
        Util::IP.get_location("www.google.com").should be_nil
        Util::IP.get_location("255.255.255.255").should be_nil
      end
    end

    describe 'public computers' do
      it "should record and recall public computers" do
        Util::IP.seed_public_computers(["192.168.0.1", "10.1.1.1", nil])
        Util::IP.is_public?("192.168.0.1").should be_true
        Util::IP.is_public?("192.168.0.2").should be_false
        Util::IP.is_public?(nil).should be_nil
      end
    end

    describe "#coordinates" do
      before do
        @ip_reasonable = Util::IP.new("8.8.8.8")
        @ip_unreasonable = Util::IP.new("255.255.255.255")
      end

      it "should return the coordinates of the IP address" do
        Util::Coordinates.coord_distance(@ip_reasonable.coordinates, Util::Coordinates.new(37.42, -122.06)).
            should be < 1
        (@ip_unreasonable).coordinates.should be_nil
      end
    end

    #this test downloads a large file from S3, so you probably don't want to run it.
    describe "#load_from_s3", :if => false do
      before do
        File.delete('lib/data/GeoLiteCity.dat') if File.exists?('lib/data/GeoLiteCity.dat')
      end

      it "should create the file GeoLiteCity.dat" do
        p "THIS IS A SLOW TEST, DID YOU REALLY WANT TO RUN IT? lib/util_spec.rb:218\n"
        Util::IP.load_from_s3
        File.exists?('lib/data/GeoLiteCity.dat').should be_true
      end
    end

    describe "address_class" do
      it "should return the class of the given IP address" do
        ip_a = "100.10.10.10"
        ip_b = "170.70.70.70"
        ip_c = "200.20.20.20"
        ip_d = "230.30.30.30"
        ip_e = "250.50.50.50"
        Util::IP.address_class(ip_a).should == :A
        Util::IP.address_class(ip_b).should == :B
        Util::IP.address_class(ip_c).should == :C
        Util::IP.address_class(ip_d).should == :D
        Util::IP.address_class(ip_e).should == :E
      end
    end
  end

  describe "#time_there" do
    it "given datetime, it returns the local datetime in timezone_2" do
      test_cases =[
          {
              tz_there: "Central Time (US & Canada)",
              time_here: DateTime.parse("2012-09-27 21:41:00 -06:00"),
              time_there: {hour: 22, minutes: 41}
          },
          {
              tz_there: "Eastern Time (US & Canada)",
              time_here: DateTime.parse("2012-09-27 21:41:00 -07:00"),
              time_there: {hour: 0, minutes: 41}
          },
          {
              tz_there: "Pacific Time (US & Canada)",
              time_here: DateTime.parse("2012-09-27 21:41:00 -04:00"),
              time_there: {hour: 18, minutes: 41}
          },
          {
              tz_there: "Central Time (US & Canada)",
              time_here: nil,
              time_there: nil
          }
      ]
      test_cases.each do |test|
        Util::time_there(test[:tz_there], test[:time_here]).should == test[:time_there]
      end
    end

    it "should not alter the time when a timezone is invalid" do
      Util::time_there(nil, DateTime.parse("2012-09-27 21:41:00 -07:00")).
          should == { hour: 21, minutes: 41 }
    end
  end


  describe "#parse_time_param" do
    it "should work in the obvious case of PST, standard time, in the morning when it is still the same day in England" do
      test_val = Util::parse_time_param('2010-01-01 09:00:00 -08:00', '(GMT+03:00) Minsk')
      test_val[:date].should == '2010-01-01'
      test_val[:time].should == '2010-01-01 09:00:00 -08:00'
      test_val[:offset].should == '-08:00'
    end

    it "should still give the correct time zone and date, even when on daylight savings time" do
      test_val = Util::parse_time_param('2010-09-08 21:56:43 -07:00', '(GMT+03:00) Minsk' )
      test_val[:date].should == '2010-09-08'
      test_val[:time].should == '2010-09-08 21:56:43 -07:00'
      test_val[:offset].should == '-07:00'
    end

    it "should handle nulls" do
      test_val = Util::parse_time_param('2010-07-01', '(GMT+03:00) Minsk')
      test_val[:time].should be_nil
      test_val[:date].should == '2010-07-01'
    end

    it "should fill in correct default offsets" do
      test_val = Util::parse_time_param('2010-09-08 21:56:43', 'Minsk')
      test_val[:offset].should == '+03:00'
    end
  end

  describe "#normalize_datetime" do
    it "should return a DateTime" do
      Util::normalize_datetime('2010-06-20 11:33:00', '(GMT-08:00) Pacific Time (US & Canada)').class.should == DateTime
    end

    it "should return the corresponding DateTime normalized to UTC" do
      # Pacific Time: observes daylight saving in June (GMT-07:00), not in December (GMT-08:00)
      Util::normalize_datetime('2010-06-20 11:33:00', 'Pacific Time (US & Canada)').to_s.
          should == '2010-06-20T18:33:00+00:00'

      Util::normalize_datetime('2010-12-20 11:33:00', 'Pacific Time (US & Canada)').to_s.
          should == '2010-12-20T19:33:00+00:00'

      # Alaska Time (similar to Pacific Time): observes daylight saving in June (GMT-08:00), not in December (GMT-09:00)
      Util::normalize_datetime('2010-06-20 11:33:00', 'Alaska').to_s.should == '2010-06-20T19:33:00+00:00'
      Util::normalize_datetime('2010-12-20 11:33:00', 'Alaska').to_s.should == '2010-12-20T20:33:00+00:00'

      # Sydney Time: observes daylight saving in December (GMT+11:00), not in June (GMT+10:00)
      Util::normalize_datetime('2010-06-20 11:33:00', 'Sydney').to_s.should == '2010-06-20T01:33:00+00:00'
      Util::normalize_datetime('2010-12-20 11:33:00', 'Sydney').to_s.should == '2010-12-20T00:33:00+00:00'

      # Vietnam Time: never observes daylight saving (GMT+07:00)
      Util::normalize_datetime('2010-06-20 11:33:00', 'Hanoi').to_s.should == '2010-06-20T04:33:00+00:00'
      Util::normalize_datetime('2010-12-20 11:33:00', 'Hanoi').to_s.should == '2010-12-20T04:33:00+00:00'
    end

    it "should include the UTC date as well as the UTC time, which may be a day off of local." do #test when the time difference changes the date, don't bother with DST
      Util::normalize_datetime('2010-12-20 23:44:00', 'Alaska').to_s.should == '2010-12-21T08:44:00+00:00'
      Util::normalize_datetime('2010-12-20 01:55:00', 'Hanoi').to_s.should == '2010-12-19T18:55:00+00:00'
    end

    it "should use the timezone in the string if provided, instead of the default timezone" do
      Util::normalize_datetime('2010-06-20 11:33:00 -09:00', 'Minsk').to_s.
          should == '2010-06-20T20:33:00+00:00'
      Util::normalize_datetime('2010-12-20 11:33:00 -09:00', 'Minsk').to_s.
          should == '2010-12-20T20:33:00+00:00'
    end

    it "should use +0:00 if it can't resolve the timezone" do
      Util.normalize_datetime('2010-06-20 11:33:00', 'this is not a valid timezone').to_s.
          should == '2010-06-20T11:33:00+00:00'
    end
  end

  describe "seconds_to_formatted_offset" do
    it "should return the formatted offset ..." do
      Util.seconds_to_formatted_offset(3600).should == "+01:00"
      Util.seconds_to_formatted_offset(-3600).should == "-01:00"
      Util.seconds_to_formatted_offset(36000).should == "+10:00"
      Util.seconds_to_formatted_offset(37800).should == "+10:30"
      Util.seconds_to_formatted_offset(36900).should == "+10:15"
      Util.seconds_to_formatted_offset(0).should == "+00:00"
    end
  end

  describe "ZipDatabase" do
    before :all do
      @zd = Util::ZipDatabase.instance
    end

    it "returns a hash of location data, even for locations in Australia" do
      @zd.find('2151', 'au')[:city].downcase.should == "north parramatta"
      @zd.find('2151', 'au')[:lat].should be_within(0.1).of(-33.776046)
      @zd.find('2151', 'au')[:long].should be_within(0.1).of(151.019885)
    end

    it "knows my home town" do
      @zd.find("93117", 'us')[:city].downcase.should == "goleta"
      @zd.find("93117", 'us')[:lat].should be_within(0.1).of(34.442592)
      @zd.find("93117", 'us')[:long].should be_within(0.1).of(-119.827589)
    end

    it "return a hash of location data, even if the postal code is stored in a truncated form eg British/Canadian" do
      @zd.find('w1j 6nr', 'gb')[:city].downcase.should == "london"
      @zd.find('s7 9ga', 'gb')[:city].downcase.should == 'sheffield'
      @zd.find('1068ep', 'nl')[:city].downcase.should == 'amsterdam nieuw west'
      @zd.find('94103-0001', 'us')[:city].downcase.should == 'san francisco'
      @zd.find('w1j6nr', 'gb')[:city].downcase.should == 'london'
      @zd.find('w1j', 'gb')[:city].downcase.should == 'london'
    end

    it "should assume the country is 'us' when the input country is nil" do
      @zd.find('93117', nil)[:city].downcase.should == 'goleta'
    end

    it "should treat the arguments as case-insensitive" do
      @zd.find("w1J", "Gb")[:city].downcase.should == 'london'
    end

    it "should return nil when bad data is given" do
      @zd.find("99999", 'us').should be_nil
      @zd.find('', nil).should be_nil
      @zd.find('', 'us').should be_nil
    end
  end

  describe "#distance" do
    before :all do
      #Mountain View is about 50km from San Francisco
      #San Francisco is about 20km from Oakland
      #Mountain View is about 503km from Marina Del Rey

      @address1 = Util::Address.new(zip: "94103") #zip code in San Francisco
      @address2 = Util::Address.new(zip: "94619") #zip code in Oakland
      @ip_address1 = Util::IP.new("8.8.8.8") #Googles DNS server in Mountain View
      @ip_address2 = Util::IP.new("192.0.43.7") #icann.org in Marina Del Rey
    end

    it "should find the distance from an address to an IP" do
      Util::distance(@address1, @ip_address1).should be_within(1).of(50)
    end

    it "should find the distance between two addresses" do
      Util::distance(@address1, @address2).should be_within(1).of(20)
    end

    it "should find the distance between two IP addresses" do
      Util::distance(@ip_address1, @ip_address2).should be_within(1).of(503)
    end

    it "should respond appropriately if given a parameter with no coordinates method" do
      expect {
        Util::distance([34.44, -119.82], [37.42, -122.04])
        }.to raise_error(TypeError)
    end
  end

  describe "numericize" do
    it "should return 0 when the parameter is nil" do
      Util::numericize(nil) { |param| param > 20 }.should == 0
    end

    it "should return 1 when the condition evaluates to true" do
      Util::numericize(25) { |param| param > 20 }.should == 1
    end

    it "should return -1 when the condition evaluates to false" do
      Util::numericize(15) { |param| param > 20}.should == -1
    end
  end

  describe Util::Order do
    describe "number_increasing" do
      it "should have a call method, that orders numbers in the canonical way" do
        col = DataColumn.new([2, 3, 1, nil])
        Util::Order::number_increasing.with_column(col).call(1, 2).should == -1
        Util::Order::number_increasing.with_column(col).call(2, 1).should == 1
        Util::Order::number_increasing.with_column(col).call(1, 1).should == 0
        [2, 3, 1].sort(&Util::Order::number_increasing.with_column(col)).should == [1, 2, 3]
      end

      it "should sort nils to the median of the given column" do
        col = DataColumn.new([100, 2, 1, nil])
        [nil, 6, 0, 1].sort(&Util::Order::number_increasing.with_column(col)).should == [0, 1, nil, 6]
      end

      ##NOTE: might want to add this spec and make it pass
      #it "should still work if no column is given" do
      #  Util::Order::number_increasing.call(1,2).should == -1
      #  Util::Order::number_increasing.call(2,1).should == 1
      #end
    end

    describe "tf_order" do
      it "should have a call method, that orders true < false" do
        Util::Order::tf_order.call(true, false).should == -1
        Util::Order::tf_order.call(false, false).should == 0
        [true, false, true].sort(&Util::Order::tf_order).should == [true, true, false]
      end

      it "should put nil between true and false" do
        Util::Order::tf_order.call(true, nil).should == -1
        Util::Order::tf_order.call(nil, false).should == -1
      end
    end

    describe "array_to_order" do
      it "should return the order on the elements of the array inherited from their indices" do
        array = [:one, :two, :three]
        order = Util::Order::array_to_order(array)
        order.call(:one, :three).should == -1
        order.call(:three, :two).should == 1
        order.call(:one, :one).should == 0
      end
    end

    describe "string_to_known_order" do
      it "should return the order suggested by the string" do
        order = Util::Order.string_to_known_order("Util::Order::tf_order")
        order.call(false, true).should == 1
      end

      it "should work with array_to_order when array is given in JSON format" do
        arr = [:one, :two, :three, true, 1]
        str = "Util::Order::array_to_order(" << arr.to_json << ")"
        order = Util::Order.string_to_known_order(str)
        order.call(:three, :one).should == 1
        order.call(1, true).should == 1
      end

      it "should work when with_column is needed" do
        col = DataColumn.new([1, 1, 5, 5])
        str = "Util::Order::number_decreasing"
        order = Util::Order.string_to_known_order(str)
        [1, 4, nil].sort(&order.with_column(col)).should == [4, nil, 1]
        order.with_column(col).call(4, nil).should == -1
      end

      it "should raise an error if the order could not be found" do
        expect {
          order = Util::Order.string_to_known_order("garbage")
        }.to raise_error
      end
    end
  end
end
