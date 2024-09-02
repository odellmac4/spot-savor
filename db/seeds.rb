require 'factory_bot_rails'
include FactoryBot::Syntax::Methods

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
table1 = create(:table, capacity: 8)
table2 = create(:table, capacity: 4)
res1 =  create(:reservation, table_id: table1.id)
res2 =  create(:reservation, table_id: table1.id)
res3 =  create(:reservation, table_id: table1.id)
res4 =  create(:reservation, start_time: DateTime.new(2024, 12, 24, 20, 0, 0), table_id: table1.id)
res5 =  create(:reservation, start_time: DateTime.new(2024, 12, 24, 20, 0, 0), table_id: table1.id)


