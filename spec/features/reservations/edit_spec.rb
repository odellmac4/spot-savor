require 'rails_helper'

RSpec.describe 'Reservation update' do
  let!(:table_1) {create(:table, capacity: 8)}
  let!(:table_2) {create(:table, capacity: 6)}

  let(:reservation_1) {create(:reservation, name: "Reyonce", start_time: DateTime.new(2024, 12, 24, 10, 0, 0), party_count: 7, table_id: table_1.id)}
  let(:reservation_2) {create(:reservation, name: "Riot Johnson", start_time: DateTime.new(2024, 11, 10, 19, 0, 0), party_count: 5, table_id: table_2.id)}

  describe 'form to edit an existing reservation' do
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

    it 'successfully updates a reservation and leads to reservation show page' do
      visit edit_reservation_path(reservation_2.id)

      within ".edit-reservation-form" do
        fill_in "reservation-name", with: "Happy"
        select "6", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "January", from: "reservation-month"
        select "12", from: "reservation-day"
        select "08:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_1.id} - Capacity: 8", from: "reservation-table"

        click_button("Update Reservation")
      end

      expect(current_path).to eq reservation_path(reservation_2.id)
      visit reservation_path(reservation_2.id)

      within ".reservation-show-details" do
        expect(page).to have_content("Party Count: 6")
        expect(page).to have_content("Reservation Date: Sun, Jan 12 2025")
        expect(page).to have_content("Reservation Time: 08:00 PM")
        expect(page).to have_content("Table #{table_1.id}")
        expect(page).to have_content("Happy")

        expect(page).to_not have_content("Party Count: 5")
        expect(page).to_not have_content("Reservation Date: Sun, Nov 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
        expect(page).to_not have_content("Reyonce")
      end

      visit reservations_path

      within "#reservation-#{reservation_2.id}" do
        expect(page).to have_content("Party Count: 6")
        expect(page).to have_content("Reservation Date: Sun, Jan 12 2025")
        expect(page).to have_content("Reservation Time: 08:00 PM")
        expect(page).to have_content("Table #{table_1.id}")
        expect(page).to have_content("Happy")

        expect(page).to_not have_content("Party Count: 5")
        expect(page).to_not have_content("Reservation Date: Sun, Nov 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
        expect(page).to_not have_content("Reyonce")
      end
    end

    it 'throws an error when trying to update reservation table where capacity is smaller than party count' do
      visit edit_reservation_path(reservation_2.id)

      within ".edit-reservation-form" do
        select "7", from: "reservation-party"
        click_button("Update Reservation")
        expect(page).to have_content "Party count is too big for the table capacity"
      end

      visit reservations_path

      within "#reservation-#{reservation_2.id}" do
        expect(page).to have_content("Party Count: 5")
        expect(page).to_not have_content("Party Count: 7")
      end
    end

    it 'throws an error when trying to update reservation start time to a time that is not at least an hour after current time' do
      visit edit_reservation_path(reservation_1.id)

      within ".edit-reservation-form" do
        select "July", from: "reservation-month"
        click_button("Update Reservation")
        expect(page).to have_content "Start time must be at least an hour after the current time"
      end

      visit reservation_path(reservation_1.id)

      within ".reservation-show-details" do
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to_not have_content("Reservation Date: Wed, Jul 10 2024")
      end

      visit reservations_path

      within "#reservation-#{reservation_1.id}" do
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to_not have_content("Reservation Date: Wed, Jul 10 2024")
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

      visit reservation_path(reservation_1.id)

      within ".reservation-show-details" do
        expect(page).to have_content('Reyonce')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table_1.id}")

        expect(page).to_not have_content("Party Count: 6")
        expect(page).to_not have_content("Reservation Date: Thu, Oct 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
      end

      visit reservations_path

      within "#reservation-#{reservation_1.id}" do
        expect(page).to have_content('Reyonce')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table_1.id}")

        expect(page).to_not have_content("Party Count: 6")
        expect(page).to_not have_content("Reservation Date: Thu, Oct 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
      end
    end

    it 'throws multiple errors if party count too big and start time is in the past' do
      visit edit_reservation_path(reservation_1.id)

      within ".edit-reservation-form" do
        select "7", from: "reservation-party"
        select "2024", from: "reservation-year"
        select "March", from: "reservation-month"
        select "10", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_2.id} - Capacity: 6", from: "reservation-table"
  
        click_button("Update Reservation")

        expect(page).to have_content "Party count is too big for the table capacity"
        expect(page).to have_content "Start time must be at least an hour after the current time"
      end

      visit reservation_path(reservation_1.id)

      within ".reservation-show-details" do
        expect(page).to have_content('Reyonce')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table_1.id}")

        expect(page).to_not have_content("Party Count: 6")
        expect(page).to_not have_content("Reservation Date: Thu, Oct 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
      end

      visit reservations_path

      within "#reservation-#{reservation_1.id}" do
        expect(page).to have_content('Reyonce')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table_1.id}")

        expect(page).to_not have_content("Party Count: 6")
        expect(page).to_not have_content("Reservation Date: Thu, Oct 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
      end
    end

    it 'throws multiple errors if party count too big and start time has already been reserved' do
      reservation = create(:reservation, start_time: DateTime.new(2025, 10, 10, 19, 0, 0), party_count: 5, table_id: table_2.id)

      visit edit_reservation_path(reservation_1.id)

      within ".edit-reservation-form" do
        select "7", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "October", from: "reservation-month"
        select "10", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_2.id} - Capacity: 6", from: "reservation-table"
  
        click_button("Update Reservation")

        expect(page).to have_content "Party count is too big for the table capacity"
        expect(page).to have_content "Start time has already been reserved"
      end

      visit reservation_path(reservation_1.id)

      within ".reservation-show-details" do
        expect(page).to have_content('Reyonce')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table_1.id}")

        expect(page).to_not have_content("Party Count: 6")
        expect(page).to_not have_content("Reservation Date: Thu, Oct 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
      end

      visit reservations_path

      within "#reservation-#{reservation_1.id}" do
        expect(page).to have_content('Reyonce')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table_1.id}")

        expect(page).to_not have_content("Party Count: 6")
        expect(page).to_not have_content("Reservation Date: Thu, Oct 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
      end
    end
  end
end