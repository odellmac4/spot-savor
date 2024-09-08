FactoryBot.define do
  factory :reservation do    
    name { Faker::Name.name.gsub(/[^a-zA-Z\s.]/, '') }
    party_count { Faker::Number.between(from: 2, to: 8) }
    start_time do
      random_date = Faker::Date.forward(days: rand(59..215))
      random_time = Faker::Time.forward(days: rand(30.100))

      start_year = Time.now.year + 1
      end_year = start_year + 3
      random_year = rand(start_year..end_year)

      DateTime.new(
        random_year,
        random_date.month,
        random_date.day,
        random_time.hour,
        0 # Set minutes to zero
      )
    end
    table { nil }
  end
end
