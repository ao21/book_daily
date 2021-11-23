FactoryBot.define do
  factory :task do
    started_on { "2021-09-15" }
    finished_on { "2021-09-21" }
    association :book
    association :user
  end
end
