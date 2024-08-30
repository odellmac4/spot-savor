FactoryBot.define do
  factory :reservation do
    name { "MyString" }
    party_count { 1 }
    start_time { "2024-08-30 12:20:16" }
    table { nil }
  end
end
