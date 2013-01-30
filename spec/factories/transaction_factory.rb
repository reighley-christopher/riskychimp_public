FactoryGirl.define do
  factory :transaction do
    association :user, factory: :user
    sequence(:transaction_id) {|n| n}

    factory :sample_transaction do
      client_id 1
      transaction_datetime DateTime.parse("2011-12-06 00:14:39 +00:00")
      sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
      name Faker::Name.name
      ip "8.8.8.8"
      shipping_city Faker::Address.city
      shipping_state Faker::Address.state
      shipping_zip Faker::Address.zip
      shipping_country Faker::Address.country
      sequence(:purchaser_id) { |n| "#{n}#{Faker::Internet.user_name}" }

      other_data {{
          account_address: Faker::Address.street_address,
          account_city: shipping_city,
          account_zip: shipping_zip,
          account_country: shipping_country,
          language: "en-us,en;q=0.5 ",
          denomination: "USD ",
          first_seen: "2011-11-25",
      }}
    end

    factory :good_transaction do
      client_id  1
      amount 50.00
      transaction_datetime DateTime.parse("2011-12-06 00:14:39 +00:00")
      email "somebody.jon@gmail.gov"
      name "Jonathan Somebody Jr."
      ip "8.8.8.8"
      shipping_city "Mountain View"
      shipping_state "CA"
      shipping_zip "94043"
      shipping_country "US"
      purchaser_id "js1"
      other_data {{
          account_address: "NULL ",
          account_city: "Los Altos ",
          account_zip: "94022 ",
          account_country: "us ",
          account_city: "Los Altos ",
          language: "en-us,en;q=0.5 ",
          denomination: "USD ",
          first_seen: "2011-11-25",
      }}

      association(:user)
    end

    factory :bad_transaction do
      client_id 1
      amount 1000000.00
      transaction_datetime DateTime.parse("2011-12-05 10:14:39 +00:00")
      email "GlobalGasCard@yahoo.com"
      name "Jonathan Nobody Jr."
      ip "8.8.8.8"
      shipping_city "Mountain View"
      shipping_state "CA"
      shipping_zip "57101"
      shipping_country "US"
      purchaser_id "js1"
      other_data {{
          account_address: "NULL ",
          account_city: "Los Altos ",
          account_zip: "94022 ",
          account_country: "us ",
          account_city: "Los Altos ",
          language: "en-us,en;q=0.5 ",
          denomination: "USD ",
          first_seen: "NULL ",
      }}

      association(:user)
    end
  end
end
