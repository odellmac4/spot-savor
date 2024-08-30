FactoryBot.define do
  factory :table do
    capacity { Faker::Number.between(from: 2, to: 8) }
  end
end
