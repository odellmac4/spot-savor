require 'rails_helper'

RSpec.describe 'Reservations index' do
  
  describe 'list of reservations' do
    let!(:table) {create(:table, capacity: 8)}
    let!(:reservations) {create_list(:reservation, 5, table_id: table.id)}
    let!(:resy_6) {create(:reservation, name: 'Odell', party_count: 7, start_time: DateTime.new(2024, 12, 24, 10, 0, 0), table_id: table.id)}

    before do
      visit reservations_path
    end

    it 'presents each attribute for a reservation' do
      reservation = reservations.first
      within "#reservation-#{reservation.id}" do
        expect(page).to have_content(reservation.name)
        expect(page).to have_content("Party Count: #{reservation.party_count}")
        expect(page).to have_content("Reservation Date: #{reservation.start_time.strftime("%a, %b %d %Y")}")
        expect(page).to have_content("Reservation Time: #{reservation.start_time.strftime("%I:%M %p")}")
        expect(page).to have_content("Table #{table.id}")
      end

      within "#reservation-#{resy_6.id}" do
        expect(page).to have_content('Odell')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table.id}")
      end
    end
  end
end