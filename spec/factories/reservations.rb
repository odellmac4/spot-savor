FactoryBot.define do
  factory :reservation do
    name { Faker::Name.name }
    party_count { Faker::Number.between(from: 2, to: 8) }
    start_time { "2024-08-31 12:20:16" }
    table { nil }
  end
end
