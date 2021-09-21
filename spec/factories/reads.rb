FactoryBot.define do
  factory :read do
    read_on { "2021-09-21" }
    read_page { "20" }
    association :task
  end
end
