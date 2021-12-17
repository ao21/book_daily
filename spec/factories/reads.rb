FactoryBot.define do
  factory :read do
    read_on { "2021-09-21" }
    sequence(:up_to_page) { |n| n + 10 }
    association :task
  end
end
