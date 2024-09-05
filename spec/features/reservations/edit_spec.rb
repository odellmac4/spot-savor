require 'rails_helper'

RSpec.describe 'Reservation update' do
  describe 'form to edit an existing reservation' do
    let(:table_1) {create(:table, capacity: 8)}
    let(:table_2) {create(:table, capacity: 6)}

    let(:reservation_1) {create(:reservation, name: "Reyonce", start_time: DateTime.new(2024, 12, 24, 10, 0, 0), party_count: 7, table_id: table_1.id)}
    let(:reservation_2) {create(:reservation, name: "Riot Johnson", start_time: DateTime.new(2024, 11, 10, 19, 0, 0), party_count: 5, table_id: table_2.id)}

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

    it 'throws an error when trying to update reservation table where capacity is smaller than party count' do
      visit edit_reservation_path(reservation_2.id)

      within ".edit-reservation-form" do

        select "7", from: "reservation-party"
  
        click_button("Update Reservation")

        expect(page).to have_content "Party count is too big for the table capacity"
      end
    end

    it 'throws an error when trying to update reservation start time to a time that is not at least an hour after current time' do
      visit edit_reservation_path(reservation_1.id)

      within ".edit-reservation-form" do

        select "July", from: "reservation-month"
  
        click_button("Update Reservation")

        expect(page).to have_content "Start time must be at least an hour after the current time"
      end
    end

    it 'throws an error when trying to update reservation to an existing date for the chosen table' do
      reservation = create(:reservation, start_time: DateTime.new(2024, 10, 10, 19, 0, 0), party_count: 5, table_id: table_2.id)

      visit edit_reservation_path(reservation_1.id)

      within ".edit-reservation-form" do

        select "6", from: "reservation-party"
        select "2024", from: "reservation-year"
        select "October", from: "reservation-month"
        select "10", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_2.id} - Capacity: 6", from: "reservation-table"
  
        click_button("Update Reservation")

        expect(page).to have_content "Start time has already been reserved"
      end
    end
  end
end