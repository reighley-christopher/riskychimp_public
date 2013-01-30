module Util
  class ZipDatabase

    def initialize
      if Location.count == 0
        populate_zip_location
      end
    end

    def self.instance
      @instance ||= new
    end

    def find(zip, country)
      country ||= "US"
      zip ||= ""
      country.strip!
      country.upcase!

      location = Location.first(:conditions => {:zip => zip, :country => country})

      if location.nil?
        zip = normalize_zip(zip, country)
        location = Location.first(:conditions => {:zip => zip, :country => country})
      end

      if location.present?
        location.attributes.symbolize_keys
          .merge!(:coordinates => Coordinates.new(location.lat, location.long))
      else
        nil
      end
    end

    TRANSFORMATIONS = {
      'GB' => lambda{ |str| str[0...(str.length - 3)].strip },
      'CA' => lambda{ |str| str[0..2] },
      'US' => lambda{ |str| str.split('-')[0] },
      'NL' => lambda{ |str| str[0...(str.length - 2)].strip }
    }

    def normalize_zip(zip, country)
      if (transformation = TRANSFORMATIONS[country])
        transformation.call(zip)
      else
        nil
      end
    end

    def load_from_s3
      raise "This method should not have been called in the test environment. You probably don't have the zip data file in #{ZIP_LOCATIONS_FILE}, check git" if Rails.env == 'test'
      https = Net::HTTP.new("riskybiz.s3.amazonaws.com", 443)
      https.use_ssl = true
      response = https.get("/geodata/zip_locations.csv")
      File.open(ZIP_LOCATIONS_FILE, 'wb') do |file|
        file.write(response.body)
      end
    end

    def populate_zip_location
      load_from_s3 unless File.exists?(ZIP_LOCATIONS_FILE)

      index = 0
      zip_location_csv_file = CSV.read(ZIP_LOCATIONS_FILE)
      if zip_location_csv_file.count != Location.count
        Location.delete_all
        zip_location_csv_file.map do |record|
          zip, city, state, lat, long, country = record
          Location.create(:zip => zip, :city => city, :state => state,
                          :lat => lat, :long => long, :country => country)
          index += 1
        end
      end
    end
  end
end
