

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

table_1 = Table.create(capacity: 8)
table_2 = Table.create(capacity: 7)
table_3 = Table.create(capacity: 6)
table_4 = Table.create(capacity: 5)
table_5 = Table.create(capacity: 5)
table_6 = Table.create(capacity: 4)
table_7 = Table.create(capacity: 3)
table_8 = Table.create(capacity: 2)
table_9 = Table.create(capacity: 8)
table_10 = Table.create(capacity: 4)

current_time = Time.zone.now
current_time_top_hour = Time.zone.local(current_time.year, current_time.month, current_time.day, current_time.hour)

reservation_1 = Reservation.create(name: "Jermaine Cole", party_count: 5, start_time: current_time_top_hour + 2000.hours, table_id: table_3.id )
reservation_2 = Reservation.create(name: "Jazmine Sullivan", party_count: 6, start_time: current_time_top_hour + 3000.hours, table_id: table_9.id )
reservation_3 = Reservation.create(name: "Brandy Norwood", party_count: 3, start_time: current_time_top_hour + 200.hours, table_id: table_7.id )
reservation_4 = Reservation.create(name: "Kehlani", party_count: 4, start_time: current_time_top_hour + 5007.hours, table_id: table_10.id )
reservation_5 = Reservation.create(name: "Erica Badu", party_count: 2, start_time: current_time_top_hour + 9453.hours, table_id: table_8.id )


