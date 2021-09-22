FactoryBot.define do
  factory :book do
    title { "factory bot" }
    author { "Joen Tester"}
    image_link { "http://test.com" }
    total_pages { "500" }
  end
end
