require 'rails_helper'

RSpec.describe 'Reservation update' do
  describe 'form to edit an existing reservation' do
    let(:table_1) {create(:table, capacity: 8)}
    let(:table_2) {create(:table, capacity: 6)}

    let(:reservation_1) {create(:reservation, name: "Reyonce", start_time: DateTime.new(2024, 12, 24, 10, 0, 0), party_count: 7, table_id: table_1.id)}
    let(:reservation_2) {create(:reservation, party_count: 6, table_id: table_2.id)}

    it 'form fields are pre-filled with reservation data' do
      visit edit_reservation_path(reservation_1.id)

      within ".edit-reservation-form" do
        expect(page).to have_field("reservation-name", with: "Reyonce")
        expect(page).to have_select("reservation-party", selected: "7")
        expect(page).to have_select("reservation-month", selected: "December")
        expect(page).to have_select("reservation-day", selected: "24")
        expect(page).to have_select("reservation-time", selected: "10:00")
        expect(page).to have_select("am-pm", selected: "AM")
        expect(page).to have_select("reservation-table", selected: "Table #{table_1.id} - Capacity: 8")
        expect(page).to have_button("Update Reservation")
      end
    end
  end
end