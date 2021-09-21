FactoryBot.define do
  factory :user do
    name { "Aaron" }
    sequence(:email) { |n| "tester#{n}@example.com" }
    password { "apple-strawberry-grape-orange" }
    password_confirmation { "apple-strawberry-grape-orange" }
  end
end
