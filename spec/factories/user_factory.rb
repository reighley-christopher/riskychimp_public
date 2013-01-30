FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "#{n}#{Faker::Internet.email}" }
    confirmed_at Time.now
    password "secret"
    password_confirmation { |u| u.password }
  end

  factory :admin, parent: :user do
    role 'admin'
  end

  factory :merchant, parent: :user do
    role 'merchant'
  end

  factory :reviewer, parent: :user do
    role 'reviewer'
    association :merchant, factory: :merchant
  end
end
