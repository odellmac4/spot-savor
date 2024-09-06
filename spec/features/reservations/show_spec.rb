require 'rails_helper'

RSpec.describe 'Reservation show page' do
  let!(:table) {create(:table, capacity: 5)}
  let!(:reservation) {create(:reservation, name: "Penny Proud", start_time: DateTime.new(2024, 9, 29, 18, 0, 0), party_count: 5, table_id: table.id)}

  before do
    visit reservation_path(reservation.id)
  end

  describe 'reservation details' do
    it 'displays all reservation details' do
      within ".reservation-show-details" do
        expect(page).to have_content "Penny Proud"
        expect(page).to have_content "Reservation Date: Sun, Sep 29 2024"
        expect(page).to have_content "Party Count: 5"
        expect(page).to have_content "Table #{table.id}"
        expect(page).to have_link("Edit Reservation", href: edit_reservation_path(reservation.id))
        expect(page).to have_link("Back to All Reservations", href: reservations_path)
      end
    end
  end
end