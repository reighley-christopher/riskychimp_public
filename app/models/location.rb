class Location < ActiveRecord::Base
  attr_accessible :zip, :city, :state, :lat, :long, :country
end
