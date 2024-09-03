require 'rails_helper'

RSpec.describe 'Reservations index' do
  
  describe 'form to initiate creation of a reservation' do
    let!(:table_1) {create(:table, capacity: 8)}
    let!(:table_2) {create(:table, capacity: 6)}
    let!(:table_3) {create(:table, capacity: 5)}
    let!(:table_4) {create(:table, capacity: 3)}

    before do
      visit reservations_path
    end

    it 'has required fields to create a reservation' do
      within ".reservation-form" do
        expect(page).to have_field("name")
        expect(page).to have_field("reservation_date")
        expect(page).to have_selector("select#reservation_time")
        expect(page).to have_select("am_pm", with_options: ["AM", "PM"])
        expect(page).to have_select("table_id", with_options: [
          "Table #{table_1.id} - Capacity: 8",
          "Table #{table_2.id} - Capacity: 6",
          "Table #{table_3.id} - Capacity: 5",
          "Table #{table_4.id} - Capacity: 3"
                ])
        expect(page).to have_button("Create Reservation")
      end
    end

    it 'fills in form with all valid information to create a reservation' do
      within ".reservation-form" do
        fill_in "name", with: "Slayana"
        select "3", from: "party_count"
        fill_in "reservation_date", with: "01/12/2025"
        select "07:00", from: "reservation_time"
        select "PM", from: "am_pm"
        select "Table #{table_4.id} - Capacity: 3", from: "table_id"

        click_button("Create Reservation")
      end

      reservation = Reservation.last
      expect(reservation.name).to eq "Slayana"
      expect(reservation.party_count).to eq 3
      expect(reservation.start_time).to eq "Sun, 12 Jan 2025 19:00:00.000000000 UTC +00:00"

      visit reservations_path

      within "#reservation-#{reservation.id}" do
        expect(page).to have_content "Slayana"
        expect(page).to have_content "Party Count: 3"
        expect(page).to have_content "Reservation Date: Sun, Jan 12 2025"
        expect(page).to have_content "Reservation Time: 07:00 PM"
        expect(page).to have_content "Table #{table_4.id}"
      end
    end

    
  end
  
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