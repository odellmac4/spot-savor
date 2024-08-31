FactoryBot.define do
  factory :reservation do    
    name { Faker::Name.name }
    party_count { Faker::Number.between(from: 2, to: 8) }
    start_time do
      random_date = Faker::Date.forward(days: 30)
      random_time = Faker::Time.forward(days: 30)
      # Create DateTime with minutes set to zero
      DateTime.new(
        random_date.year,
        random_date.month,
        random_date.day,
        random_time.hour,
        0 # Set minutes to zero
      )
    end
    table { nil }
  end
end
